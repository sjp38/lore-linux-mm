Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1A686B039B
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:12:43 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id j82so213840819ybg.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:12:43 -0800 (PST)
Received: from mail-yw0-x231.google.com (mail-yw0-x231.google.com. [2607:f8b0:4002:c05::231])
        by mx.google.com with ESMTPS id d133si156541ybc.229.2017.02.14.06.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 06:12:43 -0800 (PST)
Received: by mail-yw0-x231.google.com with SMTP id v200so66526424ywc.3
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:12:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com> <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
From: Eric Dumazet <edumazet@google.com>
Date: Tue, 14 Feb 2017 06:12:41 -0800
Message-ID: <CANn89iK6qWxqWNf+Tb7nTXNhkREKSmj=HCMSVZhDZOaw5Qo9Aw@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm <linux-mm@kvack.org>

On Tue, Feb 14, 2017 at 5:45 AM, Eric Dumazet <edumazet@google.com> wrote:
>
> Could we now please Ack this v3 and merge it ?
>

BTW I found the limitation on sender side.

After doing :

lpaa23:~# ethtool -c eth0
Coalesce parameters for eth0:
Adaptive RX: on  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 400000
pkt-rate-high: 450000

rx-usecs: 16
rx-frames: 44
rx-usecs-irq: 0
rx-frames-irq: 0

tx-usecs: 16
tx-frames: 16
tx-usecs-irq: 0
tx-frames-irq: 256

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 128
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

lpaa23:~# ethtool -C eth0 tx-usecs 8 tx-frames 8

-> 36 Gbit on a single TCP flow, this is the highest number I ever got.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
