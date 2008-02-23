Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m1NEXZsj016729
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 06:33:35 -0800
Received: from py-out-1112.google.com (pyed32.prod.google.com [10.34.156.32])
	by zps75.corp.google.com with ESMTP id m1NEXU8X020593
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 06:33:34 -0800
Received: by py-out-1112.google.com with SMTP id d32so1107589pye.12
        for <linux-mm@kvack.org>; Sat, 23 Feb 2008 06:33:34 -0800 (PST)
Message-ID: <6599ad830802230633i483c8dd1q5b541be1a92a5795@mail.gmail.com>
Date: Sat, 23 Feb 2008 06:33:34 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 2/2] ResCounter: Use read_uint in memory controller
In-Reply-To: <47BE4FB5.5040902@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080221203518.544461000@menage.corp.google.com>
	 <20080221205525.349180000@menage.corp.google.com>
	 <47BE4FB5.5040902@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, xemul@openvz.org, balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2008 at 8:29 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  Looks good, except for the name uint(), can we make it u64(). Integers are 32
>  bit on both ILP32 and LP64, but we really read/write 64 bit values.

Yes, that's true. But read_uint() is more consistent with all the
other instances in cgroups and subsystems. So if we were to call it
res_counter_read_u64() I'd also want to rename all the other
*read_uint functions/fields to *read_u64 too. Can I do that in a
separate patch?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
