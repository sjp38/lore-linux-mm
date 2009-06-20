Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F0EA96B004D
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 22:27:45 -0400 (EDT)
Message-ID: <4A3C4946.6030100@redhat.com>
Date: Fri, 19 Jun 2009 22:28:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/4] tmem: precache implementation (layered on tmem)
References: <67c05b05-c8e2-4e8f-a234-52a86e657404@default>
In-Reply-To: <67c05b05-c8e2-4e8f-a234-52a86e657404@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:

> @@ -110,6 +111,9 @@
>  		s->s_qcop = sb_quotactl_ops;
>  		s->s_op = &default_op;
>  		s->s_time_gran = 1000000000;
> +#ifdef CONFIG_PRECACHE
> +		s->precache_poolid = -1;
> +#endif
>  	}
>  out:
>  	return s;

Please generate your patches with -up so we can see
which functions are being modified by each patch hunk.
That makes it a lot easier to find the context and
see what you are trying to do.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
