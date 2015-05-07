Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 638E26B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 04:46:30 -0400 (EDT)
Received: by obcux3 with SMTP id ux3so26402326obc.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 01:46:30 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id xr4si832720obc.94.2015.05.07.01.46.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 01:46:29 -0700 (PDT)
Received: by obfe9 with SMTP id e9so26441667obf.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 01:46:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150507041220.1873.80925.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
	<20150507041220.1873.80925.stgit@ahduyck-vm-fedora22>
Date: Thu, 7 May 2015 01:46:29 -0700
Message-ID: <CAL3LdT47e8FXqXW_DeCygid0DgJjQ5Xss4fvyfn2vOXP9WPcew@mail.gmail.com>
Subject: Re: [PATCH 08/10] e1000: Replace e1000_free_frag with skb_free_frag
From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Cc: netdev <netdev@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Wed, May 6, 2015 at 9:12 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)

Was my ACK of the first patch not good enough? :-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
