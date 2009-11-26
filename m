Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D45746B0083
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 21:58:30 -0500 (EST)
Message-ID: <4B0DEEAB.4000807@redhat.com>
Date: Wed, 25 Nov 2009 21:57:47 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: do not evict inactive pages when skipping an
 active list scan
References: <20091125133752.2683c3e4@bree.surriel.com> <20091126110340.5A62.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091126110340.5A62.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, kosaki.motohiro@fujitsu.co.jp, Tomasz Chmielewski <mangoo@wpkg.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 11/25/2009 09:50 PM, KOSAKI Motohiro wrote:
>
>> -	if (lru == LRU_ACTIVE_ANON&&  inactive_anon_is_low(zone, sc)) {
>> -		shrink_active_list(nr_to_scan, zone, sc, priority, file);
>> +	if (lru == LRU_ACTIVE_ANON) {
>> +		if (inactive_file_is_low(zone, sc))
>>      
> This inactive_file_is_low() should be inactive_anon_is_low().
> cut-n-paste programming often makes similar mistake. probaby we need make
> more cleanup to this function.
>
> How about this? (this is incremental patch from you)
>
>
>    
Doh!  Nice catch...
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>
>    
Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
