Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 223966B0031
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 14:36:09 -0400 (EDT)
In-Reply-To: <1371128589-8953-22-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com> <1371128589-8953-22-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [Part1 PATCH v5 21/22] x86, mm: Make init_mem_mapping be able to be called several times
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Thu, 13 Jun 2013 14:35:28 -0400
Message-ID: <aad34de7-8ff7-442d-ad8a-bed2a6e3edea@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Jacob Shin <jacob.shin@amd.com>

Tang Chen <tangchen@cn.fujitsu.com> wrote:

>From: Yinghai Lu <yinghai@kern=
el.org>
>
>Prepare to put page table on local nodes.
>
>Move calling of ini=
t_mem_mapping() to early_initmem_init().
>
>Rework alloc_low_pages to alloc=
ate page table in following order:
>	BRK, local node, low range
>
>Still on=
ly load_cr3 one time, otherwise we would break xen 64bit again.
>



Sigh..=
  Can that comment on Xen be removed please.  The issue was fixed last rele=
ase  and I believe I already asked to remove that comment as it is not true=
 anymore. 
-- 
Sent from my Android phone. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
