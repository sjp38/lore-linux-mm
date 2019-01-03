Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EAC978E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 05:15:37 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id s3so32723108iob.15
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 02:15:37 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e8si562935jaj.17.2019.01.03.02.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 02:15:37 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2] netfilter: account ebt_table_info to kmemcg
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190103031431.247970-1-shakeelb@google.com>
Date: Thu, 3 Jan 2019 03:14:56 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <313C6566-289D-4973-BB15-857EED858DA3@oracle.com>
References: <20190103031431.247970-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Florian Westphal <fw@strlen.de>, Kirill Tkhai <ktkhai@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org



> On Jan 2, 2019, at 8:14 PM, Shakeel Butt <shakeelb@google.com> wrote:
>=20
> 	countersize =3D COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
> -	newinfo =3D vmalloc(sizeof(*newinfo) + countersize);
> +	newinfo =3D __vmalloc(sizeof(*newinfo) + countersize, =
GFP_KERNEL_ACCOUNT,
> +			    PAGE_KERNEL);
> 	if (!newinfo)
> 		return -ENOMEM;
>=20
> 	if (countersize)
> 		memset(newinfo->counters, 0, countersize);
>=20
> -	newinfo->entries =3D vmalloc(tmp.entries_size);
> +	newinfo->entries =3D __vmalloc(tmp.entries_size, =
GFP_KERNEL_ACCOUNT,
> +				     PAGE_KERNEL);
> 	if (!newinfo->entries) {
> 		ret =3D -ENOMEM;
> 		goto free_newinfo;
> --=20

Just out of curiosity, what are the actual sizes of these areas in =
typical use
given __vmalloc() will be allocating by the page?

   =20
