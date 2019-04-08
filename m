Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F1C7C10F0E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 02:18:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E1B920883
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 02:18:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="TpLju8xx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E1B920883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB9176B000E; Sun,  7 Apr 2019 22:18:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A68206B0010; Sun,  7 Apr 2019 22:18:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9594D6B0266; Sun,  7 Apr 2019 22:18:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74AEA6B000E
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 22:18:48 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f15so11390379qtk.16
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 19:18:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QGrPOs7NcK88mGiIdZN7etxYjvNgl8QMTOMOjy/LUJk=;
        b=ENYn4H5Up7nxlzE2EH61WCcuLD7me3WTElJoc8ROQGjk4t2a4o0dEn+G/lrj+hpqWn
         RrrkrNWJ/6zK/ZES4WPZGP/CnDXFRKBZBgA63HeyqmbTtpD/XKL2zV/5Ktsj9XK5Awgi
         Qkx3OYZ6sNTYnI2RG1jNNwFBwZnyS6KiXnDJSCuyQvSAXUZIrge+HsjyZ3v5O1D7+7pH
         4+dxGl9Ngs+XheUm9xLsk5S+JxNrceEktKsmZ5J9y4kaz4jxY8Sl2swdcWO11LbJVwOF
         H+bCak21KExtGdXlpb1r0WG63BPLLvWdC3nDH1kO3qkUTpmdVvMHNDjoWgUNXelIIyHb
         UPQw==
X-Gm-Message-State: APjAAAX4R7xnAZ9yLLxRBm6wcrPbrOgnZI8WuwNAN7Tt0aZTafTAr3EZ
	ncZQnuBVvc5sWIpeaRNE3a0s/CswoTuZ9rfDzJXL1kcCRnt+QmZKL6ED5rAnPT5XSVzzYhb0pDY
	OK9O/EZq313M1yYNLoDGRnAc2+2o413mrPtz1RXQf73MLzxAshjbt3nvPJIDiIkaTNg==
X-Received: by 2002:a0c:d217:: with SMTP id m23mr21849945qvh.154.1554689928167;
        Sun, 07 Apr 2019 19:18:48 -0700 (PDT)
X-Received: by 2002:a0c:d217:: with SMTP id m23mr21849910qvh.154.1554689927585;
        Sun, 07 Apr 2019 19:18:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554689927; cv=none;
        d=google.com; s=arc-20160816;
        b=wW3GepXS8aRLTB7zZRL6N96Nd7i8f7Ni247BGbmVDunhwhqAEP1eOObGyUh8DxbaMq
         7kC/vzEXbkk1Er2mXUCiTNCWpgU3HvZwWasPWma9ZEp7A68TOQTf0jC4I6uOvvKrPX2T
         X8WFb699ZS51i92JG/lLU1JsnkpLflHnD4bRzkyFhRjsCfrFQtWiypVgimkOsPHvvwDN
         4TYr7sHr7BErj+tj5VXtpCRYNWWaiH3aSYzcZShO4LbGsMyZ8cEfC7zE+lyTJ2K+mX/v
         g0jDVy6t33kgVpk9FcyGxItL1jbzeLfo+PkrPQ21xLf+KCObJK1BirV0Ae4XI6vu8UjD
         Ku4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=QGrPOs7NcK88mGiIdZN7etxYjvNgl8QMTOMOjy/LUJk=;
        b=RiXJ9QGY/e02Cllpbp4DXg1zIDpoUUdGG7CUBXv/mR95MuKRrnHEKmUSfpPTAGSv45
         /W164TYS5cvERHeWseARa3qt+Yu3NHPCRXIvchHydzBrdECX1nh2quHTDu+GPTfmxMxG
         o8HqLB4v4nFd0YubYq8veyZwaFUJp6uT3+/W3k7Pwe835f9zvtGOEc5BkIC0PSRujgEa
         LxMl29hXTqJEs8lxxaF13AGVBV2Epu+9yGzeunp7yr1RtD71jIeLivxsIRYjjy9LsMkk
         0d38jSOwkrRy/7EUBtQFuanD+5Jg7SaPOBlpzlT5Db0EvMe9X1Nehik7j8bUX068Ea/l
         qB4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=TpLju8xx;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i31sor28631042qvc.47.2019.04.07.19.18.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Apr 2019 19:18:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=TpLju8xx;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=QGrPOs7NcK88mGiIdZN7etxYjvNgl8QMTOMOjy/LUJk=;
        b=TpLju8xxzRgC51DnkCB0GS3K+vgDB8xwXY57kmRhHcWKQGud75plI9ZxdQTdsLStDE
         phUbCXO8Yl2yzcuaw0G13/by+dhDya4wZr/+19cZQ1hGhBPmukaW1nLITkqktbI6yGp8
         GcqLX0k07tEQ12tPb0pcJD+YTi5YUcMFdgcD22hLXbxpMP+r1S0RtIqrcLK1nWR5AcmM
         7WscM7CLPv2qq3DBv+0tDTsJgpo+k/JQAy2a/SgZQsuYAGX29PHDwn9xtNaoYw9XfC7k
         mtnW4C3bq3cKuSLOYJyw8jk018PEAvbEysaY/Z1o75AlYL7AE8YAhCu7ULpShhZ6dI7f
         +BzA==
X-Google-Smtp-Source: APXvYqxcoZyXI1YDx24c/6j/v6GrCpgt95qjxx1ZMbOd5tw2+rs5OCMmfVIg3PgOkSBgKwR5kkiTNg==
X-Received: by 2002:a0c:ba10:: with SMTP id w16mr21954196qvf.115.1554689927244;
        Sun, 07 Apr 2019 19:18:47 -0700 (PDT)
Received: from ovpn-120-238.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id 204sm15771391qki.58.2019.04.07.19.18.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 19:18:46 -0700 (PDT)
Subject: Re: [PATCH] slab: fix a crash by reading /proc/slab_allocators
To: "Tobin C. Harding" <me@tobin.cc>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org,
 rientjes@google.com, iamjoonsoo.kim@lge.com, tj@kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190406225901.35465-1-cai@lca.pw>
 <20190408015917.GA633@eros.localdomain>
From: Qian Cai <cai@lca.pw>
Message-ID: <57f7ef12-9330-a535-64c9-6bf17382d5fc@lca.pw>
Date: Sun, 7 Apr 2019 22:18:45 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190408015917.GA633@eros.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/7/19 9:59 PM, Tobin C. Harding wrote:
> On Sat, Apr 06, 2019 at 06:59:01PM -0400, Qian Cai wrote:
>> The commit 510ded33e075 ("slab: implement slab_root_caches list")
>> changes the name of the list node within "struct kmem_cache" from
>> "list" to "root_caches_node"
> 
> Are you sure? It looks to me like it adds a member to the memcg_cache_array
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index a0cc7a77cda2..af1a5bef80f4 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -556,6 +556,8 @@ struct memcg_cache_array {
>   *             used to index child cachces during allocation and cleared
>   *             early during shutdown.
>   * 
> + * @root_caches_node: List node for slab_root_caches list.
> + * 
>   * @children:  List of all child caches.  While the child caches are also
>   *             reachable through @memcg_caches, a child cache remains on
>   *             this list until it is actually destroyed.
> @@ -573,6 +575,7 @@ struct memcg_cache_params {
>         union { 
>                 struct {
>                         struct memcg_cache_array __rcu *memcg_caches;
> +                       struct list_head __root_caches_node;
>                         struct list_head children;
>                 };
> 
> And then defines 'root_caches_node' to be 'memcg_params.__root_caches_node'
> if we have CONFIG_MEMCG otherwise defines 'root_caches_node' to be 'list'
> 
> 
>> but leaks_show() still use the "list"
> 
> I believe it should since 'list' is used to add to slab_caches list.

See the offensive commit 510ded33e075 which changed those.

@@ -1136,12 +1146,12 @@ static void print_slabinfo_header(struct seq_file *m)
 void *slab_start(struct seq_file *m, loff_t *pos)
 {
        mutex_lock(&slab_mutex);
-       return seq_list_start(&slab_caches, *pos);
+       return seq_list_start(&slab_root_caches, *pos);
 }

 void *slab_next(struct seq_file *m, void *p, loff_t *pos)
 {
-       return seq_list_next(p, &slab_caches, pos);
+       return seq_list_next(p, &slab_root_caches, pos);
 }

and then memcg_link_cache() does,

if (is_root_cache(s)) {
	list_add(&s->root_caches_node, &slab_root_caches);

memcg_unlink_cache() does,

if (is_root_cache(s)) {
	list_del(&s->root_caches_node);

It also changed /proc/slabinfo but forgot to change /proc/slab_allocators.

@@ -1193,12 +1203,11 @@ static void cache_show(struct kmem_cache *s, struct
seq_file *m)

 static int slab_show(struct seq_file *m, void *p)
 {
-       struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
+       struct kmem_cache *s = list_entry(p, struct kmem_cache, root_caches_node);

> 
>> which causes a crash when reading /proc/slab_allocators.
> 
> I was unable to reproduce this crash, I built with
> 
> # CONFIG_MEMCG is not set
> CONFIG_SLAB=y
> CONFIG_SLAB_MERGE_DEFAULT=y
> CONFIG_SLAB_FREELIST_RANDOM=y
> CONFIG_DEBUG_SLAB=y
> CONFIG_DEBUG_SLAB_LEAK=y
> 
> I then booted in Qemu and successfully ran 
> $ cat slab_allocators
> 
> Perhaps you could post your config?

Yes, it won't be reproducible without CONFIG_MEMCG=y, because it has,

/* If !memcg, all caches are root. */
#define slab_root_caches       slab_caches
#define root_caches_node       list

Anyway,

https://git.sr.ht/~cai/linux-debug/blob/master/config

