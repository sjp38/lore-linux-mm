Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id CE17A6B00F4
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 10:16:16 -0500 (EST)
Message-ID: <1329491770.2293.278.camel@twins>
Subject: Re: [PATCH 2/2] rmap: anon_vma_prepare: Reduce code duplication by
 calling anon_vma_chain_link
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 17 Feb 2012 16:16:10 +0100
In-Reply-To: <1329488908-7304-1-git-send-email-consul.kautuk@gmail.com>
References: <1329488908-7304-1-git-send-email-consul.kautuk@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-02-17 at 09:28 -0500, Kautuk Consul wrote:
> Reduce code duplication by calling anon_vma_chain_link from
> anon_vma_prepare.
>=20
> Also move the anon_vmal_chain_link function to a more suitable location
> in the file.
>=20
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
