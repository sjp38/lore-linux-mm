Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDD76B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 20:41:48 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so166055034pff.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 17:41:48 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id 7si68815080pfl.182.2016.01.04.17.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 17:41:47 -0800 (PST)
Received: by mail-pa0-x235.google.com with SMTP id uo6so186408440pac.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 17:41:47 -0800 (PST)
Date: Mon, 4 Jan 2016 17:41:48 -0800
From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: BUG: Bad rss-counter state mm:ffff8800c5a96000 idx:3 val:3894
Message-ID: <20160105014148.GA24491@hudson.localdomain>
References: <20151224171253.GA3148@hudson.localdomain>
 <20160104132203.6e4f59fd0d1734bd92133ca2@linux-foundation.org>
 <20160104224629.GA16271@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160104224629.GA16271@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Will Drewry <wad@chromium.org>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

all,

On Tue, Jan 05, 2016 at 12:46:30AM +0200, Kirill A. Shutemov wrote:
> On Mon, Jan 04, 2016 at 01:22:03PM -0800, Andrew Morton wrote:
> > On Thu, 24 Dec 2015 09:12:53 -0800 Jeremiah Mahler <jmmahler@gmail.com> wrote:
> > 
> > > all,
> > > 
> > > I have started seeing a "Bad rss-counter" message in the logs with
> > > the latest linux-next 20151222+.
> > > 
> > >   [  458.282192] BUG: Bad rss-counter state mm:ffff8800c5a96000 idx:3 val:3894
> > > 
> > > I can test patches if anyone has any ideas.
> > > 
> > > -- 
> > > - Jeremiah Mahler
> > 
> > Thanks.  cc's added.
> 
> IIUC, it's been fixed already, no?
> 
> http://lkml.kernel.org/r/20151229185729.GA2209@hudson.localdomain
> 
> -- 
>  Kirill A. Shutemov

Yes, it is fixed in the latest linux-next.

-- 
- Jeremiah Mahler

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
