Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAL5pRUL005770
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:51:27 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAL5qm0D069512
	for <linux-mm@kvack.org>; Sun, 20 Nov 2005 22:52:48 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAL5pRUl024537
	for <linux-mm@kvack.org>; Sun, 20 Nov 2005 22:51:27 -0700
Message-ID: <4381605F.3040300@us.ibm.com>
Date: Sun, 20 Nov 2005 21:51:27 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/8] Create emergency trigger
References: <437E2C69.4000708@us.ibm.com>	<437E2D57.9050304@us.ibm.com> <20051118162112.7bf21df5.pj@sgi.com>
In-Reply-To: <20051118162112.7bf21df5.pj@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
>>@@ -876,6 +879,16 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
>> 	int can_try_harder;
>> 	int did_some_progress;
>> 
>>+	if (is_emergency_alloc(gfp_mask)) {
> 
> 
> Can this check for is_emergency_alloc be moved lower in __alloc_pages?
> 
> I don't see any reason why most __alloc_pages() calls, that succeed
> easily in the first loop over the zonelist, have to make this check.
> This would save one conditional test and jump on the most heavily
> used code path in __alloc_pages().

Good point, Paul.  Will make sure that gets moved.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
