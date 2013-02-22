Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id C97076B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 17:38:52 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 22 Feb 2013 17:38:50 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 663026E804F
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 17:38:45 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1MMckNt274450
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 17:38:46 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1MMcTFo018538
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 15:38:29 -0700
Message-ID: <5127F35F.2030200@linux.vnet.ibm.com>
Date: Fri, 22 Feb 2013 14:38:23 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC][ATTEND] topics I'd like to discuss
References: <51279035.5050304@redhat.com> <5127E601.6080202@redhat.com>
In-Reply-To: <5127E601.6080202@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, Larry Woodman <lwoodman@redhat.com>

On 02/22/2013 01:41 PM, Rik van Riel wrote:
>> 2.) Replication of pagecache pages on NUMA nodes.
> 
> What about this would you like to discuss?
> 
> Is there some proposal of code to do this?

I did an implementation _long_ ago:

	http://lwn.net/Articles/63512/

Might be fun for someone to glean an idea or two from, although I'm sure
the code has long since bitrotted in to being useless.  It was kinda fun
to read, though. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
