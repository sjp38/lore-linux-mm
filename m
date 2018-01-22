Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7997F800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 18:23:19 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y111so7750367wrc.2
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 15:23:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w76si271835wme.167.2018.01.22.15.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 15:23:18 -0800 (PST)
Date: Mon, 22 Jan 2018 15:23:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Per file OOM badness
Message-Id: <20180122152315.749d88f3c91ffce4d70ac450@linux-foundation.org>
In-Reply-To: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, Christian.Koenig@amd.com

On Thu, 18 Jan 2018 11:47:48 -0500 Andrey Grodzovsky <andrey.grodzovsky@amd=
.com> wrote:

> Hi, this series is a revised version of an RFC sent by Christian K=F6nig
> a few years ago. The original RFC can be found at=20
> https://lists.freedesktop.org/archives/dri-devel/2015-September/089778.ht=
ml
>=20
> This is the same idea and I've just adressed his concern from the origina=
l RFC=20
> and switched to a callback into file_ops instead of a new member in struc=
t file.

Should be in address_space_operations, I suspect.  If an application
opens a file twice, we only want to count it once?

But we're putting the cart ahead of the horse here.  Please provide us
with a detailed description of the problem which you are addressing so
that the MM developers can better consider how to address your
requirements.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
