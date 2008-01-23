Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0NJce49016188
	for <linux-mm@kvack.org>; Wed, 23 Jan 2008 14:38:40 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0NJcZFS044598
	for <linux-mm@kvack.org>; Wed, 23 Jan 2008 12:38:36 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0NJcZFq020990
	for <linux-mm@kvack.org>; Wed, 23 Jan 2008 12:38:35 -0700
Subject: Re: [RFC] Userspace tracing memory mappings
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20080123160454.GA15405@Krystal>
References: <20080123160454.GA15405@Krystal>
Content-Type: text/plain
Date: Wed, 23 Jan 2008 11:38:32 -0800
Message-Id: <1201117112.8329.9.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: mbligh@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-23 at 11:04 -0500, Mathieu Desnoyers wrote:
> Since memory management is not my speciality, I would like to know if
> there are some implementation details I should be aware of for my
> LTTng userspace tracing buffers. Here is what I want to do :

Can you start with a little background by telling us what a userspace
tracing buffer _is_?  Maybe a few requirements about what you need it to
do and why, as well?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
