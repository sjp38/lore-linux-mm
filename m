Message-ID: <45C363F3.2000207@argo.co.il>
Date: Fri, 02 Feb 2007 18:16:51 +0200
From: Avi Kivity <avi@argo.co.il>
MIME-Version: 1.0
Subject: Re: [PATCH]Convert highest_possible_processor_id to nr_cpu_ids
References: <Pine.LNX.4.64.0701291437590.1067@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701291437590.1067@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> This follows up on the patch to create nr_node_ids... Patch against 
> 2.6.20-rc6 + Andrew's fix for mistakenly replacing  
> highest_possible_processor_id() with nr_node_ids.
>
>
>
>   

[!CONFIG_SMP]

> -#define highest_possible_processor_id()	0
> +#define nr_cpu_ids			0
>   

Shouldn't this be 1?

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
