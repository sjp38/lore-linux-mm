Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 2B8FE6B0069
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 20:51:49 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 9 Jul 2012 18:51:48 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 5BE71C90052
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 20:51:46 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6A0pknY409210
	for <linux-mm@kvack.org>; Mon, 9 Jul 2012 20:51:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6A0pjrj006814
	for <linux-mm@kvack.org>; Mon, 9 Jul 2012 20:51:45 -0400
Date: Tue, 10 Jul 2012 08:51:40 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: more comments for skip_free_areas_node()
Message-ID: <20120710005140.GA5557@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1341545097-9933-1-git-send-email-shangw@linux.vnet.ibm.com>
 <CAM_iQpUQN0EEFf5G3RMiR5_51-Pfm2n1kqtQhRuTjQz-wvsmjw@mail.gmail.com>
 <20120706054639.GA32570@shangw>
 <alpine.DEB.2.00.1207091417430.23926@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1207091417430.23926@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon, Jul 09, 2012 at 02:21:07PM -0700, David Rientjes wrote:
>On Fri, 6 Jul 2012, Gavin Shan wrote:
>
>> >> The initial idea comes from Cong Wang. We're running out of memory
>> >> while calling function skip_free_areas_node(). So it would be unsafe
>> >> to allocate more memory from either stack or heap. The patche adds
>> >> more comments to address that.
>> >
>> >I think these comments should add to show_free_areas(),
>> >not skip_free_areas_node().
>> >
>> 
>> aha, exactly. Thanks a lot, Cong.
>> 
>
>There are two issues you're trying to describe here that I told you about:
>
> - allocating memory on the stack when called in a potentially very deep 
>   call chain, and
>
> - dynamically allocating memory in oom conditions.
>
>There are thousands of functions that could be called potentially very 
>deep in a call chain, there's nothing special about this one besides the 
>fact that you tried to optimize it by allocating a nodemask on the stack 
>in a previous patch.
>
>show_mem(), which calls show_free_areas(), is also not called only in oom 
>conditions so the comment wouldn't apply at all.
>
>In other words, there's nothing special about this particular function 
>with regard to these traits.
>

Thanks for your review, David. So please drop it :-)

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
