Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 709846B0036
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 22:43:13 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up7so5829978pbc.12
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 19:43:13 -0700 (PDT)
Received: from psmtp.com ([74.125.245.182])
        by mx.google.com with SMTP id iu9si11545381pac.234.2013.10.27.19.43.11
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 19:43:12 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 28 Oct 2013 12:43:07 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 2F16C2BB0054
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 13:43:05 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9S2gp8C6357250
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 13:42:53 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9S2h3UX013937
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 13:43:03 +1100
Date: Mon, 28 Oct 2013 10:43:01 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] percpu: little optimization on calculating
 pcpu_unit_size
Message-ID: <20131028024301.GB15642@weiyang.vnet.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1382345893-6644-3-git-send-email-weiyang@linux.vnet.ibm.com>
 <20131027123634.GL14934@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131027123634.GL14934@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Oct 27, 2013 at 08:36:34AM -0400, Tejun Heo wrote:
>On Mon, Oct 21, 2013 at 04:58:13PM +0800, Wei Yang wrote:
>> pcpu_unit_size exactly equals to ai->unit_size.
>> 
>> This patch assign this value instead of calculating from pcpu_unit_pages. Also
>> it reorder them to make it looks more friendly to audience.
>
>Ditto.  I'd rather not change unless this is clearly better.

This one change an assignement to a shift, which in my mind is a little
faster.

Well, this is just executed once during the boot time, not a big deal.

>
>Thanks.
>
>-- 
>tejun

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
