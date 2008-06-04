Message-ID: <48463C14.4000705@cn.fujitsu.com>
Date: Wed, 04 Jun 2008 14:54:12 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com> <20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

> Index: temp-2.6.26-rc2-mm1/Documentation/controllers/resource_counter.txt
> ===================================================================
> --- temp-2.6.26-rc2-mm1.orig/Documentation/controllers/resource_counter.txt
> +++ temp-2.6.26-rc2-mm1/Documentation/controllers/resource_counter.txt
> @@ -44,6 +44,13 @@ to work with it.
>   	Protects changes of the above values.
>  
>  
> + f. struct res_counter *parent
> +
> +	Parent res_counter under hierarchy.
> +
> + g. unsigned long long for_children
> +
> +	Resources assigned to children. This is included in usage.

Since parent and for_children are also protected by res_count->lock,
the above text should appear before 'e. spinlock_t lock'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
