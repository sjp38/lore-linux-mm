Date: Fri, 9 Mar 2007 13:27:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] [PATCH] Power Managed memory base enabling
In-Reply-To: <20070309205344.GA16777@linux.intel.com>
Message-ID: <Pine.LNX.4.64.0703091326270.13252@chino.kir.corp.google.com>
References: <20070305181826.GA21515@linux.intel.com>
 <Pine.LNX.4.64.0703051941310.18703@chino.kir.corp.google.com>
 <20070306164722.GB22725@linux.intel.com> <Pine.LNX.4.64.0703061838390.13314@chino.kir.corp.google.com>
 <20070309205344.GA16777@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Gross <mgross@linux.intel.com>
Cc: linux-mm@kvack.org, linux-pm@lists.osdl.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, mark.gross@intel.com, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Mar 2007, Mark Gross wrote:

> +int __nearest_non_pm_node(int nid)
> +{
> +	int i, dist, closest, temp;
> +	
> +	if (!__power_managed_node(nid))
> +		return nid;
> +	dist = closest= 255;
> +	for_each_node(i) {

Shouldn't this be for_each_online_node(i) ?

> +		if (__power_managed_node(i))
> +			continue;
> +
> +		if (i != nid) {
> +			temp = __node_distance(nid, i );
> +			if (temp < dist) {
> +				closest = i;
> +				dist = temp;
> +			}
> +		}
> +	}
> +	BUG_ON(closest == 255);
> +	return closest;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
