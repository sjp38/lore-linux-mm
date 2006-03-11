Received: by wproxy.gmail.com with SMTP id i4so210359wra
        for <linux-mm@kvack.org>; Sat, 11 Mar 2006 03:56:28 -0800 (PST)
Message-ID: <aec7e5c30603110356w3c866498v5d43c69454bf476e@mail.gmail.com>
Date: Sat, 11 Mar 2006 20:56:28 +0900
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 00/03] Unmapped: Separate unmapped and mapped pages
In-Reply-To: <Pine.LNX.4.64.0603101111570.28805@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
	 <Pine.LNX.4.64.0603101111570.28805@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/11/06, Christoph Lameter <clameter@sgi.com> wrote:
> On Fri, 10 Mar 2006, Magnus Damm wrote:
>
> > Unmapped patches - Use two LRU:s per zone.
>
> Note that if this is done then the default case of zone_reclaim becomes
> trivial to deal with and we can get rid of the zone_reclaim_interval.

That's a good thing, right? =)

> However, I have not looked at the rest yet.

Please do. I'd like to hear what you think about it.

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
