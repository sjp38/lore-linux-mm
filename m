Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1096B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 06:00:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g71so7580100wmg.13
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:00:01 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id u18si3822564edb.541.2017.08.09.03.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 03:00:00 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id q189so6185189wmd.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:00:00 -0700 (PDT)
Date: Wed, 9 Aug 2017 12:59:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170809095957.kv47or2w4obaipkn@node.shutemov.name>
References: <20170806140425.20937-1-riel@redhat.com>
 <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz>
 <1502117991.6577.13.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1502117991.6577.13.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, dave.hansen@intel.com, linux-api@vger.kernel.org

On Mon, Aug 07, 2017 at 10:59:51AM -0400, Rik van Riel wrote:
> On Mon, 2017-08-07 at 15:46 +0200, Michal Hocko wrote:
> > On Mon 07-08-17 15:22:57, Michal Hocko wrote:
> > > This is an user visible API so make sure you CC linux-api (added)
> > > 
> > > On Sun 06-08-17 10:04:23, Rik van Riel wrote:
> > > > 
> > > > A further complication is the proliferation of clone flags,
> > > > programs bypassing glibc's functions to call clone directly,
> > > > and programs calling unshare, causing the glibc pthread_atfork
> > > > hook to not get called.
> > > > 
> > > > It would be better to have the kernel take care of this
> > > > automatically.
> > > > 
> > > > This is similar to the OpenBSD minherit syscall with
> > > > MAP_INHERIT_ZERO:
> > > > 
> > > >     https://man.openbsd.org/minherit.2
> > 
> > I would argue that a MAP_$FOO flag would be more appropriate. Or do
> > you
> > see any cases where such a special mapping would need to change the
> > semantic and inherit the content over the fork again?
> > 
> > I do not like the madvise because it is an advise and as such it can
> > be
> > ignored/not implemented and that shouldn't have any correctness
> > effects
> > on the child process.
> 
> Too late for that. VM_DONTFORK is already implemented
> through MADV_DONTFORK & MADV_DOFORK, in a way that is
> very similar to the MADV_WIPEONFORK from these patches.

It's not obvious to me what would break if kernel would ignore
MADV_DONTFORK or MADV_DONTDUMP.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
