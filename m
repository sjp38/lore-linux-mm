Received: by wx-out-0506.google.com with SMTP id h31so2506931wxd
        for <linux-mm@kvack.org>; Mon, 17 Sep 2007 10:49:56 -0700 (PDT)
From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH][RESEND] maps: PSS(proportional set size) accounting in smaps
Date: Mon, 17 Sep 2007 18:49:20 +0100
References: <389996856.30386@ustc.edu.cn> <20070916235120.713c6102.akpm@linux-foundation.org> <20070917161027.GY4219@waste.org>
In-Reply-To: <20070917161027.GY4219@waste.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709171849.20306.vda.linux@googlemail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <wfg@mail.ustc.edu.cn>, John Berthels <jjberthels@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Matt,

On Monday 17 September 2007 17:10, Matt Mackall wrote:
> Also, there's a second number we should be reporting at the same
> time, which I've been calling USS (unique or unshared set size), which
> is the size of the unshared pages. This is, for example, the amount of
> memory that will get freed when you kill one of 20 Apache threads, or,
> alternately, the amount of memory that adding another one will consume.

USS is already there, smaps already gives you that.

If you read entire smaps "file" and sum up all numbers there:

Shared_Clean: N
Shared_Dirty: N
Private_Clean: N
Private_Dirty: N

Then you can calculate the following (among other useful things):

rss_sh   - sum of (shared_clean + shared_dirty)
uss      - sum of (private_clean + private_dirty) <=== HERE
rss      - uss + rss_sh

PSS, on the other hand, cannot be inferred from this data,
so please push it into mainline.
--
vda

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
