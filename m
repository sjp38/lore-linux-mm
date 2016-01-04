Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 32B306B0007
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 17:46:33 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l65so3049504wmf.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 14:46:33 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id kh8si148296252wjb.218.2016.01.04.14.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 14:46:32 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id l65so3049116wmf.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 14:46:31 -0800 (PST)
Date: Tue, 5 Jan 2016 00:46:30 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: BUG: Bad rss-counter state mm:ffff8800c5a96000 idx:3 val:3894
Message-ID: <20160104224629.GA16271@node.shutemov.name>
References: <20151224171253.GA3148@hudson.localdomain>
 <20160104132203.6e4f59fd0d1734bd92133ca2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160104132203.6e4f59fd0d1734bd92133ca2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jeremiah Mahler <jmmahler@gmail.com>, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Will Drewry <wad@chromium.org>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Jan 04, 2016 at 01:22:03PM -0800, Andrew Morton wrote:
> On Thu, 24 Dec 2015 09:12:53 -0800 Jeremiah Mahler <jmmahler@gmail.com> wrote:
> 
> > all,
> > 
> > I have started seeing a "Bad rss-counter" message in the logs with
> > the latest linux-next 20151222+.
> > 
> >   [  458.282192] BUG: Bad rss-counter state mm:ffff8800c5a96000 idx:3 val:3894
> > 
> > I can test patches if anyone has any ideas.
> > 
> > -- 
> > - Jeremiah Mahler
> 
> Thanks.  cc's added.

IIUC, it's been fixed already, no?

http://lkml.kernel.org/r/20151229185729.GA2209@hudson.localdomain

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
