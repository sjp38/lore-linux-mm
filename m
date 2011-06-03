Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 83AEB6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 10:34:05 -0400 (EDT)
Message-ID: <4DE8F0D4.2090008@tilera.com>
Date: Fri, 3 Jun 2011 10:33:56 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: always align cpu_slab to honor cmpxchg_double requirement
References: <201106021424.p52EO91O006974@lab-17.internal.tilera.com> <alpine.DEB.2.00.1106021015220.18350@chino.kir.corp.google.com> <4DE7D2AC.1070503@tilera.com> <BANLkTinjCbhiwRfQ_aN5wtbYipQB6gv5AA@mail.gmail.com> <alpine.DEB.2.00.1106030905590.27151@router.home>
In-Reply-To: <alpine.DEB.2.00.1106030905590.27151@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 6/3/2011 10:06 AM, Christoph Lameter wrote:
> On Fri, 3 Jun 2011, Pekka Enberg wrote:
>
>> On Thu, Jun 2, 2011 at 9:13 PM, Chris Metcalf <cmetcalf@tilera.com> wrote:
>> > On 6/2/2011 1:16 PM, David Rientjes wrote:
>> >> Acked-by: David Rientjes <rientjes@google.com>
>> Yup. Looks good. Christoph?
> Ok if we do not mind the packing density to be not that tight anymore.
>
> Acked-by: Christoph Lameter <cl@linux.com>

I'm assuming from the acks that I should ask Linus to pull this for 3.0
along with a couple of other minor tile-specific changes.  However, please
let me know if someone else would rather take it into their tree instead --
I don't want to step on any toes.  Thanks!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
