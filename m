Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 2D07C6B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 14:23:22 -0400 (EDT)
Message-ID: <514B4F9C.5040000@redhat.com>
Date: Thu, 21 Mar 2013 14:21:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/10] mm: vmscan: Have kswapd writeback pages based on
 dirty pages encountered, not priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-7-git-send-email-mgorman@suse.de> <m2620qjdeo.fsf@firstfloor.org> <20130317151155.GC2026@suse.de> <514B4925.2010909@redhat.com> <20130321181532.GP1878@suse.de>
In-Reply-To: <20130321181532.GP1878@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/21/2013 02:15 PM, Mel Gorman wrote:
> On Thu, Mar 21, 2013 at 01:53:41PM -0400, Rik van Riel wrote:
>> On 03/17/2013 11:11 AM, Mel Gorman wrote:
>>> On Sun, Mar 17, 2013 at 07:42:39AM -0700, Andi Kleen wrote:
>>>> Mel Gorman <mgorman@suse.de> writes:
>>>>
>>>>> @@ -495,6 +495,9 @@ typedef enum {
>>>>>   	ZONE_CONGESTED,			/* zone has many dirty pages backed by
>>>>>   					 * a congested BDI
>>>>>   					 */
>>>>> +	ZONE_DIRTY,			/* reclaim scanning has recently found
>>>>> +					 * many dirty file pages
>>>>> +					 */
>>>>
>>>> Needs a better name. ZONE_DIRTY_CONGESTED ?
>>>>
>>>
>>> That might be confusing. The underlying BDI is not necessarily
>>> congested. I accept your point though and will try thinking of a better
>>> name.
>>
>> ZONE_LOTS_DIRTY ?
>>
>
> I had changed it to
>
>          ZONE_TAIL_LRU_DIRTY,            /* reclaim scanning has recently found
>                                           * many dirty file pages at the tail
>                                           * of the LRU.
>                                           */
>
> Is that reasonable?

Works for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
