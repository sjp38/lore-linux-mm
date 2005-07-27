Date: Wed, 27 Jul 2005 16:33:56 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] VM: add capabilites check to set_zone_reclaim
In-Reply-To: <20050727221424.GW9492@localhost>
Message-ID: <Pine.LNX.4.62.0507271633050.28636@graphe.net>
References: <20050727221424.GW9492@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jul 2005, Martin Hicks wrote:

>  	struct zone *z;
>  	int i;
>  
> +        if (!capable(CAP_SYS_ADMIN))
> +                return -EACCES;
> +
>  	if (node >= MAX_NUMNODES || !node_online(node))
>  		return -EINVAL;

Fix the whitespace issues.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
