Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6IK8TeR364688
	for <linux-mm@kvack.org>; Mon, 18 Jul 2005 16:08:33 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6IK8TuY433760
	for <linux-mm@kvack.org>; Mon, 18 Jul 2005 14:08:29 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6IK8NlX007029
	for <linux-mm@kvack.org>; Mon, 18 Jul 2005 14:08:23 -0600
Received: from austin.ibm.com (netmail2.austin.ibm.com [9.41.248.176])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j6IK8NGk006774
	for <linux-mm@kvack.org>; Mon, 18 Jul 2005 14:08:23 -0600
Message-ID: <42DC0C29.30000@austin.ibm.com>
Date: Mon, 18 Jul 2005 15:08:09 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
References: <1121101013.15095.19.camel@localhost> <42D2AE0F.8020809@austin.ibm.com> <20050711195540.681182d0.pj@sgi.com> <Pine.LNX.4.58.0507121353470.32323@skynet> <20050712132940.148a9490.pj@sgi.com> <Pine.LNX.4.58.0507130815420.1174@skynet> <20050714040613.10b244ee.pj@sgi.com> <Pine.LNX.4.58.0507181328480.2899@skynet>
In-Reply-To: <Pine.LNX.4.58.0507181328480.2899@skynet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Paul Jackson <pj@sgi.com>, haveblue@us.ibm.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> +static char *type_names[RCLM_TYPES] = { "Kernnel Unreclaimable",

You picked up my typo.  Otherwise I've integrated these two patches back 
into my own.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
