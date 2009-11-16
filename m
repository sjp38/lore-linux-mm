From: Milan Broz <mbroz@redhat.com>
Subject: Re: [PATCH 0/7] Reduce GFP_ATOMIC allocation failures, candidate
 fix V3
Date: Mon, 16 Nov 2009 17:44:07 +0100
Message-ID: <4B018157.3080707__32615.4126938947$1258389922$gmane$org@redhat.com>
References: <1258054211-2854-1-git-send-email-mel@csn.ul.ie> <20091112202748.GC2811@think> <20091112220005.GD2811@think> <20091113024642.GA7771@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 224C56B004D
	for <linux-mm@kvack.org>; Mon, 16 Nov 2009 11:45:09 -0500 (EST)
In-Reply-To: <20091113024642.GA7771@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>
List-Id: linux-mm.kvack.org

On 11/13/2009 03:46 AM, Chris Mason wrote:
> On Thu, Nov 12, 2009 at 05:00:05PM -0500, Chris Mason wrote:
> 
> [ ...]
> 
>>
>> The punch line is that the btrfs guy thinks we can solve all of this with
>> just one more thread.  If we change dm-crypt to have a thread dedicated
>> to sync IO and a thread dedicated to async IO the system should smooth
>> out.

Please, can you cc DM maintainers with these kind of patches? dm-devel list at least.

Note that the crypt requests can be already processed synchronously or asynchronously,
depending on used crypto module (async it is in the case of some hw acceleration).

Adding another queue make the situation more complicated and because the crypt
requests can be queued in crypto layer I am not sure that this solution will help
in this situation at all.
(Try to run that with AES-NI acceleration for example.)


Milan
--
mbroz@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
