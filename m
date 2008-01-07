Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m07KHgPR023947
	for <linux-mm@kvack.org>; Mon, 7 Jan 2008 20:17:45 GMT
Received: from fg-out-1718.google.com (fgae12.prod.google.com [10.86.56.12])
	by zps75.corp.google.com with ESMTP id m07KHcbO002360
	for <linux-mm@kvack.org>; Mon, 7 Jan 2008 12:17:41 -0800
Received: by fg-out-1718.google.com with SMTP id e12so4520402fga.8
        for <linux-mm@kvack.org>; Mon, 07 Jan 2008 12:17:38 -0800 (PST)
Message-ID: <d43160c70801071217r514fc45ai4252b907986c26de@mail.gmail.com>
Date: Mon, 7 Jan 2008 15:17:38 -0500
From: "Ross Biro" <rossb@google.com>
Subject: Re: RFC/Patch Make Page Tables Relocatable Part 2/2 Page Table Migration Code
In-Reply-To: <Pine.LNX.4.64.0801071149160.23617@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70801040802p2a6d96c8p406eb391cbd829e4@mail.gmail.com>
	 <Pine.LNX.4.64.0801071149160.23617@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Jan 7, 2008 2:49 PM, Christoph Lameter <clameter@sgi.com> wrote:
> Interesting approach. It moves all page table pages even if only a subset
> of the address space was migrated?

That's a side effect of not understanding the page migration code.  I
couldn't figure out where to hook into the existing code, so I did it
the easy way and migrated everything.  Passing around an address range
or other subset representation and only migrating some of the page
tables would be a trivial addition.  But not one that makes any sense
until the page table migration code is integrated into the rest of the
migration code properly.  I'm assuming someone else will point out the
proper place to hook into the existing code, and then only migrating a
portion of the page tables will be easy.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
