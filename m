Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05268680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 16:56:50 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id e137so45770584itc.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 13:56:50 -0800 (PST)
Received: from mail-it0-x22a.google.com (mail-it0-x22a.google.com. [2607:f8b0:4001:c0b::22a])
        by mx.google.com with ESMTPS id w19si2183531ioi.6.2017.02.14.13.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 13:56:49 -0800 (PST)
Received: by mail-it0-x22a.google.com with SMTP id c7so52523414itd.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 13:56:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170214210219.1ea87229@redhat.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com> <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com> <CAKgT0UdRmpV_n1wstTHvqCgyRtze8z1rTJ5pKc_jdRttQCSySw@mail.gmail.com>
 <20170214194615.3feddd07@redhat.com> <CANn89iK4fnsjsK+GHYdT7_F0f++sa+t2LqrZWftjEryhF=hX+w@mail.gmail.com>
 <20170214210219.1ea87229@redhat.com>
From: Eric Dumazet <edumazet@google.com>
Date: Tue, 14 Feb 2017 13:56:47 -0800
Message-ID: <CANn89iK6Ecf2NNxKLy83WYK3WnuinGWc9J03UOpFROOWqE=Bog@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, Tariq Toukan <ttoukan.linux@gmail.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm <linux-mm@kvack.org>

>
> This obviously does not work for the case I'm talking about
> (transmitting out another device with XDP).
>

XDP_TX does not handle this yet.

When XDP_TX was added, it was very clear that the transmit _had_ to be
done on the same port.

Since all this discussion happened in this thread ( mlx4: use order-0
pages for RX )
I was kind of assuming all the comments were relevant to current code or patch,
not future devs ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
