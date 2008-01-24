Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m0OFDFhs005337
	for <linux-mm@kvack.org>; Thu, 24 Jan 2008 07:13:15 -0800
Received: from fg-out-1718.google.com (fge22.prod.google.com [10.86.5.22])
	by zps76.corp.google.com with ESMTP id m0OFCN9e018760
	for <linux-mm@kvack.org>; Thu, 24 Jan 2008 07:13:14 -0800
Received: by fg-out-1718.google.com with SMTP id 22so253513fge.26
        for <linux-mm@kvack.org>; Thu, 24 Jan 2008 07:13:14 -0800 (PST)
Message-ID: <d43160c70801240713p1e7121c0k94ba210233a69dbb@mail.gmail.com>
Date: Thu, 24 Jan 2008 10:13:14 -0500
From: "Ross Biro" <rossb@google.com>
Subject: Re: [RFC][PATCH 1/2]: MM: Make Paget Tables Relocatable--Conditional TLB Flush
In-Reply-To: <20080124140913.5FFE.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080123161340.A1AAEDCA00@localhost>
	 <20080124140913.5FFE.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Jan 24, 2008 12:20 AM, Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> This is a nitpick, but all of archtectures code except generic use
> MMF_NNED_FLUSH at clear_bit()...

I'd say that's a bit more than a nit.  Thanks for noticing that.
Please hang on, I think I've figured out how to reduce the 3.5% page
fault overhead to almost nothing.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
