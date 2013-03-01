Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 65FF56B0006
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 12:48:49 -0500 (EST)
Date: Fri, 1 Mar 2013 17:48:52 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH v2 1/2] mm: tuning hardcoded reserved memory
Message-ID: <20130301174852.5d568191@www.etchedpixels.co.uk>
In-Reply-To: <20130228034803.GB3829@localhost.localdomain>
References: <20130227205629.GA8429@localhost.localdomain>
	<20130228141200.3fe7f459.akpm@linux-foundation.org>
	<20130228034803.GB3829@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The 3% reserve was added to the original code *because* users kept hitting
problems where they couldn't recover. 

I suspect the tunable should nowdays be something related to min(3%,
someconstant), at the time we did the 3% I think 1GB was an "enterprise
system" ;)

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
