Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 493906B0083
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 08:28:59 -0500 (EST)
Message-ID: <4F5610D3.2030907@parallels.com>
Date: Tue, 6 Mar 2012 17:27:47 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] checkpatch: Warn on use of yield()
References: <20120302112358.GA3481@suse.de>   <1330723262.11248.233.camel@twins>   <20120305121804.3b4daed4.akpm@linux-foundation.org>   <1330999280.10358.3.camel@joe2Laptop> <1331037942.11248.307.camel@twins>  <4F560DA8.5040302@parallels.com> <1331040318.11248.311.camel@twins>
In-Reply-To: <1331040318.11248.311.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Miao Xie <miaox@cn.fujitsu.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>

On 03/06/2012 05:25 PM, Peter Zijlstra wrote:
> On Tue, 2012-03-06 at 17:14 +0400, Glauber Costa wrote:
>>
>> Can't we point people to some Documentation file that explains the
>> alternatives?
>
> Not sure that's a finite set.. however I think we covered the most
> popular ones in this thread. One could use a lkml.kernel.org link.
>
Yes, I think that would work. Summarizing your arguments in an in-tree 
Documentation file would be good as well, IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
