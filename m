Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6527C6B039F
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 11:22:32 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f66so113615614ioe.12
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 08:22:32 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id 37si12137339iod.71.2017.04.17.08.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 08:22:31 -0700 (PDT)
Date: Mon, 17 Apr 2017 10:22:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <20170411193948.GA29154@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1704171021450.28407@east.gentwo.org>
References: <20170411134618.GN6729@dhcp22.suse.cz> <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com> <20170411141956.GP6729@dhcp22.suse.cz> <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org> <20170411164134.GA21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111254390.25069@east.gentwo.org> <20170411183035.GD21171@dhcp22.suse.cz> <alpine.DEB.2.20.1704111335540.6544@east.gentwo.org> <20170411185555.GE21171@dhcp22.suse.cz> <alpine.DEB.2.20.1704111356460.6911@east.gentwo.org>
 <20170411193948.GA29154@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Apr 2017, Michal Hocko wrote:

> On Tue 11-04-17 13:59:44, Cristopher Lameter wrote:
> > On Tue, 11 Apr 2017, Michal Hocko wrote:
> >
> > > I didn't say anything like that. Hence the proposed patch which still
> > > needs some more thinking and evaluation.
> >
> > This patch does not even affect kfree().
>
> Ehm? Are we even talking about the same thing? The whole discussion was
> to catch invalid pointers to _kfree_ and why BUG* is not the best way to
> handle that.

The patch does not do that. See my review. Invalid points to kfree are
already caught with a bug on. See kfree in mm/slub.c


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
