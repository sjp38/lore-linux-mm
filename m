Received: by xproxy.gmail.com with SMTP id h28so3163499wxd
        for <linux-mm@kvack.org>; Tue, 15 Nov 2005 14:19:34 -0800 (PST)
Message-ID: <eada2a070511151419j5d94ec55xb36c6ae7d17ea30a@mail.gmail.com>
Date: Tue, 15 Nov 2005 14:19:33 -0800
From: Tim Pepper <lnxninja@us.ibm.com>
Subject: Re: [PATCH] Add NUMA policy support for huge pages.
In-Reply-To: <Pine.LNX.4.62.0511151342310.10995@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <Pine.LNX.4.62.0511151342310.10995@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 11/15/05, Christoph Lameter <clameter@engr.sgi.com> wrote:
> --- linux-2.6.14-mm2.orig/mm/mempolicy.c        2005-11-15 10:29:53.000000000 -0800
> +++ linux-2.6.14-mm2/mm/mempolicy.c     2005-11-15 12:30:26.000000000 -0800
> @@ -1005,6 +1005,34 @@ static unsigned offset_il_node(struct me
>         return nid;
>  }
>
> +/* Caculate a node number for interleave */
      ^^^^^

Calculate even...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
