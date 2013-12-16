Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id D20786B0037
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:20:31 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so5755765pbb.4
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:20:31 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qh6si9472938pbb.4.2013.12.16.09.20.29
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 09:20:30 -0800 (PST)
Date: Mon, 16 Dec 2013 09:20:29 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC][PATCH 1/7] mm: print more details for bad_page()
Message-ID: <20131216172029.GY22695@tassilo.jf.intel.com>
References: <20131213235903.8236C539@viggo.jf.intel.com>
 <20131213235904.D69C09F7@viggo.jf.intel.com>
 <00000142fc5326bf-37eaf439-1c10-448f-9cd3-8137290680ca-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000142fc5326bf-37eaf439-1c10-448f-9cd3-8137290680ca-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Dec 16, 2013 at 04:52:57PM +0000, Christoph Lameter wrote:
> On Fri, 13 Dec 2013, Dave Hansen wrote:
> 
> > This way, the messages will show specifically why the page was
> > bad, *specifically* which flags it is complaining about, if it
> > was a page flag combination which was the problem.
> 
> Yes this would have been helpful in the past for me.

Yes, for me too. </AOL>

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
