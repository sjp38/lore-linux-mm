Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC186B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 20:28:11 -0400 (EDT)
Received: by oica37 with SMTP id a37so125472362oic.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 17:28:11 -0700 (PDT)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id pm5si9078218oec.87.2015.05.04.17.28.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 17:28:10 -0700 (PDT)
Received: by obcux3 with SMTP id ux3so118653987obc.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 17:28:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150504231505.1538.58292.stgit@ahduyck-vm-fedora22>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
	<20150504231505.1538.58292.stgit@ahduyck-vm-fedora22>
Date: Mon, 4 May 2015 17:28:10 -0700
Message-ID: <CAL3LdT58zGo8tDSassf5EGFhL48wpQOuiA+9sX4d53fCGjpiAQ@mail.gmail.com>
Subject: Re: [net-next PATCH 4/6] e1000: Replace e1000_free_frag with skb_free_frag
From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Cc: linux-mm@kvack.org, netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>

On Mon, May 4, 2015 at 4:15 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)
>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
