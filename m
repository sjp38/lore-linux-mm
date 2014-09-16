Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1827C6B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 02:56:05 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id z12so4910787wgg.28
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 23:56:05 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id n9si981251wic.14.2014.09.15.23.56.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 23:56:04 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id em10so5549748wid.16
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 23:56:04 -0700 (PDT)
Date: Tue, 16 Sep 2014 08:56:00 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RESEND] x86: numa: setup_node_data(): drop dead code and rename
 function
Message-ID: <20140916065600.GE14807@gmail.com>
References: <20140915142540.0a24c887@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140915142540.0a24c887@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: mingo@elte.hu, hpa@zytor.com, tglx@linutronix.de, akpm@linux-foundation.org, rientjes@google.com, andi@firstfloor.org, riel@redhat.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Luiz Capitulino <lcapitulino@redhat.com> wrote:

> The setup_node_data() function allocates a pg_data_t object, inserts it
> into the node_data[] array and initializes the following fields: node_id,
> node_start_pfn and node_spanned_pages.

Applied to the tip:x86/mm tree for v3.18 integration.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
