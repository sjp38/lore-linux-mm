Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 329DC6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 02:25:50 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q185so79939qke.0
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 23:25:50 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t135si7923036qke.309.2018.04.05.23.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 23:25:48 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 1/1 v2] vmscan: Support multiple kswapd threads per
 node
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
In-Reply-To: <20180405061015.GU6312@dhcp22.suse.cz>
Date: Thu, 5 Apr 2018 23:25:14 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <99DC1801-1ADC-488B-BA8D-736BCE4BA372@oracle.com>
References: <1522878594-52281-1-git-send-email-buddy.lumpkin@oracle.com>
 <20180405061015.GU6312@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org


> On Apr 4, 2018, at 11:10 PM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Wed 04-04-18 21:49:54, Buddy Lumpkin wrote:
>> v2:
>> - Make update_kswapd_threads_node less racy
>> - Handle locking for case where CONFIG_MEMORY_HOTPLUG=3Dn
>=20
> Please do not repost with such a small changes. It is much more
> important to sort out the big picture first and only then deal with
> minor implementation details. The more versions you post the more
> fragmented and messy the discussion will become.
>=20
> You will have to be patient because this is a rather big change and it
> will take _quite_ some time to get sorted.
>=20
> Thanks!
> --=20
> Michal Hocko
> SUSE Labs
>=20


Sorry about that, I actually had three people review my code internally,
then I managed to send out an old version. 100% guilty of submitting
code when I needed sleep. As for the change, that was in response
to a request from Andrew to make the update function less racy.

Should I resend a correct v2 now that the thread exists?

=E2=80=94Buddy=
