Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFC2EC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:42:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EE892186A
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:42:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EE892186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF3F66B0266; Thu, 11 Apr 2019 10:42:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA2B56B0269; Thu, 11 Apr 2019 10:42:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D93B26B026A; Thu, 11 Apr 2019 10:42:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABEC16B0266
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:42:58 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id c21so2852913oig.20
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:42:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=crbSSw9RRq2gqjnga1aijJ75H8zXaneGIClC4ImS2/0=;
        b=ibpyuOPhi5Oe2vyKovw7OZwDYJoxSBJ3p55Y/708c2Cca/inLyjsccNfoerCbCt02z
         G9vOppJHu7T6al6tMisGiT6re01Hm2dYhxbL+6S3zxiGfh59hNly7E3EKcI1ugzurN32
         BFDnP0zAWJ+Z44U+ytT3edArcYqtNCIcPpGFH79SkZrQxpQ8VAdjtLcn7GJrTJinbcZZ
         JXes8Hfq6IcaUKsNfJGNjyusPnMz7WGqFfeKQvWp7yrD8h7qm8hGO+fIlnDSEFEsRJF5
         K3U9JFrY/HvbgLn4hlBC6q4SQIx0FQORJVVY1qiHRihkGUIQLgvAdmWzYV80dQKefFfJ
         2Olw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUCECWSxKC2p+sWVI65XJjnumILeQuFhRkah5nH8tAVrV8GPAA4
	f58Kgs0p7C+JyhIp3vqksMxcH3LNSJBavHMG76ahpR+e1wslIw3g88mZ1ZAiYmGm47V3tM8dOew
	3Vv/q8xXJdtKQOFLLwEN2cCUknsp3eN3O4b7jj1N84l+my+2sFI93Kt02dbga6N0=
X-Received: by 2002:aca:c683:: with SMTP id w125mr6647166oif.144.1554993778120;
        Thu, 11 Apr 2019 07:42:58 -0700 (PDT)
X-Received: by 2002:aca:c683:: with SMTP id w125mr6647111oif.144.1554993777034;
        Thu, 11 Apr 2019 07:42:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554993777; cv=none;
        d=google.com; s=arc-20160816;
        b=e00xiTCJALDr8YGcjzca/5EMUY8gv6ieR2Dzh6nIEf0DVW7ZVIAoKZMF0NOwG/4V9B
         wZLoWZz3VsFH+vKh72XotOF7tvotkGDf0ZOnWDSGNx4b0FbDIPDJ5RGmX50uffGqcGne
         J9pDahpu5eFKMdQi6z1P37wGBQPHxKYk5mNYNKi+Ti6AK9/3ISL8aAOo5fQ2QpolxQYL
         mNeL3hyAA9VEXA/g60AYe9/CyD2Nb0khfjU/ZtkCMNUQSpBTi4At3e90v70W7IQ6zYUl
         jFwUR9zAEtoy77jqFjp1g8WBgBl9HuDxNgzZcRUBjrhjXYBQN+Qk8yCZpgMIPAy6cov6
         KCZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=crbSSw9RRq2gqjnga1aijJ75H8zXaneGIClC4ImS2/0=;
        b=hQ8lQus/Wyt3W0Y4e7f9jhRPX4SNFomi/yJbpraMign63TcJ/c5+P1DfTmZTxwq1Ym
         r9nGI717RWxJhkIuofK5D7257JA41XkGAnbhrAIXPbWvvMA683i5g4pSViFsX5UO7OQ3
         z7I8wHqLyDCR3lrNK1r9Pl+NNSVNDD++kQ4aW/YtZjoRVVe1P5XcQrUMz+Q8YCJn1/wy
         61mtkuL31pEFSF0pSzCAgqa3cmGWKiR329AynHME9NgmHCu2uO7blH2024czwX83wY/K
         hd0Uy4dUSnUcNJqDucPOIkGyLXH9G3vsU1s3hxpfJKGLCGEjCFCNlu8d/vWW4cm4Ju9+
         JXLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o63sor20318848oig.124.2019.04.11.07.42.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 07:42:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqzFQAIrlFxpwlyEWoq6CpQY9y7nONO4rSZruvAoVkbHDac1JeCFyyQ2POUfLRzzHqsFQ84OyxDxuZpXgiMC5Vs=
X-Received: by 2002:aca:eb93:: with SMTP id j141mr6329300oih.178.1554993776444;
 Thu, 11 Apr 2019 07:42:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190409214415.3722-1-keith.busch@intel.com>
In-Reply-To: <20190409214415.3722-1-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 11 Apr 2019 16:42:45 +0200
Message-ID: <CAJZ5v0gOuHSoMd6dnGKN5fW1xKF89b2ak0F4mo+07FBpFUCP6A@mail.gmail.com>
Subject: Re: [PATCH] hmat: Register attributes for memory hot add
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Rafael Wysocki <rafael@kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, 
	Brice Goglin <Brice.Goglin@inria.fr>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 9, 2019 at 11:42 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Some types of memory nodes that HMAT describes may not be online at the
> time we initially parse their nodes' tables. If the node should be set
> to online later, as can happen when using PMEM as RAM after boot, the
> node's attributes will be missing their initiator links and performance.
>
> Regsiter a memory notifier callback and set the memory attributes when
> a node is initially brought online with hot added memory, and don't try
> to register node attributes if the node is not online during initial
> scanning.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/hmat/hmat.c | 63 ++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 50 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index b275016ff648..cf24b885feb5 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -14,14 +14,15 @@
>  #include <linux/init.h>
>  #include <linux/list.h>
>  #include <linux/list_sort.h>
> +#include <linux/memory.h>
>  #include <linux/node.h>
>  #include <linux/sysfs.h>
>
> -static __initdata u8 hmat_revision;
> +static u8 hmat_revision;
>
> -static __initdata LIST_HEAD(targets);
> -static __initdata LIST_HEAD(initiators);
> -static __initdata LIST_HEAD(localities);
> +static LIST_HEAD(targets);
> +static LIST_HEAD(initiators);
> +static LIST_HEAD(localities);
>
>  /*
>   * The defined enum order is used to prioritize attributes to break ties when
> @@ -41,6 +42,7 @@ struct memory_target {
>         unsigned int memory_pxm;
>         unsigned int processor_pxm;
>         struct node_hmem_attrs hmem_attrs;
> +       bool registered;
>  };
>
>  struct memory_initiator {
> @@ -53,7 +55,7 @@ struct memory_locality {
>         struct acpi_hmat_locality *hmat_loc;
>  };
>
> -static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
> +static struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
>  {
>         struct memory_initiator *initiator;
>
> @@ -63,7 +65,7 @@ static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
>         return NULL;
>  }
>
> -static __init struct memory_target *find_mem_target(unsigned int mem_pxm)
> +static struct memory_target *find_mem_target(unsigned int mem_pxm)
>  {
>         struct memory_target *target;
>
> @@ -148,7 +150,7 @@ static __init const char *hmat_data_type_suffix(u8 type)
>         }
>  }
>
> -static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
> +static u32 hmat_normalize(u16 entry, u64 base, u8 type)
>  {
>         u32 value;
>
> @@ -183,7 +185,7 @@ static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
>         return value;
>  }
>
> -static __init void hmat_update_target_access(struct memory_target *target,
> +static void hmat_update_target_access(struct memory_target *target,
>                                              u8 type, u32 value)
>  {
>         switch (type) {
> @@ -435,7 +437,7 @@ static __init int srat_parse_mem_affinity(union acpi_subtable_headers *header,
>         return 0;
>  }
>
> -static __init u32 hmat_initiator_perf(struct memory_target *target,
> +static u32 hmat_initiator_perf(struct memory_target *target,
>                                struct memory_initiator *initiator,
>                                struct acpi_hmat_locality *hmat_loc)
>  {
> @@ -473,7 +475,7 @@ static __init u32 hmat_initiator_perf(struct memory_target *target,
>                               hmat_loc->data_type);
>  }
>
> -static __init bool hmat_update_best(u8 type, u32 value, u32 *best)
> +static bool hmat_update_best(u8 type, u32 value, u32 *best)
>  {
>         bool updated = false;
>
> @@ -517,7 +519,7 @@ static int initiator_cmp(void *priv, struct list_head *a, struct list_head *b)
>         return ia->processor_pxm - ib->processor_pxm;
>  }
>
> -static __init void hmat_register_target_initiators(struct memory_target *target)
> +static void hmat_register_target_initiators(struct memory_target *target)
>  {
>         static DECLARE_BITMAP(p_nodes, MAX_NUMNODES);
>         struct memory_initiator *initiator;
> @@ -577,22 +579,53 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
>         }
>  }
>
> -static __init void hmat_register_target_perf(struct memory_target *target)
> +static void hmat_register_target_perf(struct memory_target *target)
>  {
>         unsigned mem_nid = pxm_to_node(target->memory_pxm);
>         node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
>  }
>
> -static __init void hmat_register_targets(void)
> +static void hmat_register_targets(void)
>  {
>         struct memory_target *target;
>
>         list_for_each_entry(target, &targets, node) {
> +               if (!node_online(pxm_to_node(target->memory_pxm)))
> +                       continue;
> +
>                 hmat_register_target_initiators(target);
>                 hmat_register_target_perf(target);
> +               target->registered = true;
>         }
>  }
>
> +static int hmat_callback(struct notifier_block *self,
> +                        unsigned long action, void *arg)
> +{
> +       struct memory_notify *mnb = arg;
> +       int pxm, nid = mnb->status_change_nid;
> +       struct memory_target *target;
> +
> +       if (nid == NUMA_NO_NODE || action != MEM_ONLINE)
> +               return NOTIFY_OK;
> +
> +       pxm = node_to_pxm(nid);
> +       target = find_mem_target(pxm);
> +       if (!target || target->registered)
> +               return NOTIFY_OK;
> +
> +       hmat_register_target_initiators(target);
> +       hmat_register_target_perf(target);
> +       target->registered = true;
> +
> +       return NOTIFY_OK;
> +}

This appears to assume that there will never be any races between the
two functions above.

It this guaranteed to be the case?

> +
> +static struct notifier_block hmat_callback_nb = {
> +       .notifier_call = hmat_callback,
> +       .priority = 2,
> +};
> +
>  static __init void hmat_free_structures(void)
>  {
>         struct memory_target *target, *tnext;
> @@ -658,6 +691,10 @@ static __init int hmat_init(void)
>                 }
>         }
>         hmat_register_targets();
> +
> +       /* Keep the table and structures if the notifier may use them */
> +       if (!register_hotmemory_notifier(&hmat_callback_nb))
> +               return 0;
>  out_put:
>         hmat_free_structures();
>         acpi_put_table(tbl);
> --

