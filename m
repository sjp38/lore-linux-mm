Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id E71E66B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 09:50:55 -0400 (EDT)
Received: by wgs2 with SMTP id 2so39565497wgs.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 06:50:55 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id ba2si11786530wib.73.2015.03.23.06.50.53
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 06:50:54 -0700 (PDT)
Date: Mon, 23 Mar 2015 15:50:48 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 11/24] huge tmpfs: shrinker to migrate and free underused
 holes
Message-ID: <20150323135048.GA31544@node.dhcp.inet.fi>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
 <alpine.LSU.2.11.1502202008010.14414@eggly.anvils>
 <550AFFD5.40607@yandex-team.ru>
 <alpine.LSU.2.11.1503222046510.5278@eggly.anvils>
 <20150323125009.GC30088@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150323125009.GC30088@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 23, 2015 at 02:50:09PM +0200, Kirill A. Shutemov wrote:
> On Sun, Mar 22, 2015 at 09:40:02PM -0700, Hugh Dickins wrote:
> > (I think Kirill has a problem of that kind in his page_remove_rmap scan).
> 
> Ouch! Thanks for noticing this. 
> 
> It should work fine while we are anon-THP only, but it need to be fixed to
> work with files.

Err. No, it must be fixed for anon-THP too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
