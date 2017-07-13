Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08481440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 02:32:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v26so45956541pfa.0
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 23:32:40 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id l2si3728274pln.468.2017.07.12.23.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 23:32:39 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id q85so6018365pfq.2
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 23:32:39 -0700 (PDT)
Date: Thu, 13 Jul 2017 16:32:28 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 0/5] Cache coherent device memory (CDM) with HMM v4
Message-ID: <20170713163228.5b49eea9@firefly.ozlabs.ibm.com>
In-Reply-To: <20170712180607.2885-1-jglisse@redhat.com>
References: <20170712180607.2885-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>

On Wed, 12 Jul 2017 14:06:02 -0400
J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:

> Changes since v3:
>   - change name to device host (s/DEVICE_PUBLIC/DEVICE_HOST/)

I think you've mis-interpreted what Dan said

The message @
http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1441839.html
states

"I was suggesting MEMORY_DEVICE_HOST for persistent memory and
MEMORY_DEVICE_PUBLIC as you want for CDM."

I guess we get to keep DEVICE_PUBLIC and move persistent memory
to MEMORY_DEVICE_HOST

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
