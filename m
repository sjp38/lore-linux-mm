Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5A7680FBF
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:03:12 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so56876049wjy.6
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 08:03:12 -0800 (PST)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id s138si3195328ita.90.2017.02.14.08.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 08:03:10 -0800 (PST)
Received: by mail-it0-x235.google.com with SMTP id c7so37791978itd.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 08:03:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1487087488.8227.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com> <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com> <1487087488.8227.53.camel@edumazet-glaptop3.roam.corp.google.com>
From: Eric Dumazet <edumazet@google.com>
Date: Tue, 14 Feb 2017 08:03:05 -0800
Message-ID: <CANn89iK2YaThRzWtcaFRi01FuJ874krD0b5orzVtDqijkdtbvw@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tariq Toukan <ttoukan.linux@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, linux-mm <linux-mm@kvack.org>

> Anything _relying_ on order-3 pages being available to impress
> friends/customers is a lie.
>

BTW, you do understand that on PowerPC right now, an Ethernet frame
holds 65536*8 =  half a MByte , right ?

So any PowerPC host using mlx4 NIC can easily be bringed down, by
using a few TCP flows and sending out of order packets.

That is in itself quite scary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
