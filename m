Date: Wed, 22 Aug 2007 13:50:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.23-rc3-mm1 kernel BUG at mm/page_alloc.c:2876!
Message-Id: <20070822135024.dde8ef5a.akpm@linux-foundation.org>
In-Reply-To: <20070822134800.ce5a5a69.akpm@linux-foundation.org>
References: <46CC9A7A.2030404@linux.vnet.ibm.com>
	<20070822134800.ce5a5a69.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 13:48:00 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> This:
> 
> --- a/mm/page_alloc.c~a
> +++ a/mm/page_alloc.c
> @@ -2814,6 +2814,8 @@ static int __cpuinit process_zones(int c
>  	return 0;
>  bad:
>  	for_each_zone(dzone) {
> +		if (!populated_zone(zone))
> +			continue;		
>  		if (dzone == zone)
>  			break;
>  		kfree(zone_pcp(dzone, cpu));
> _
> 
> might help avoid the crash

err, make that

--- a/mm/page_alloc.c~a
+++ a/mm/page_alloc.c
@@ -2814,6 +2814,8 @@ static int __cpuinit process_zones(int c
 	return 0;
 bad:
 	for_each_zone(dzone) {
+		if (!populated_zone(dzone))
+			continue;
 		if (dzone == zone)
 			break;
 		kfree(zone_pcp(dzone, cpu));
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
