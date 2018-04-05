Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1076C6B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 12:42:56 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g61-v6so19739151plb.10
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 09:42:56 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0097.outbound.protection.outlook.com. [104.47.32.97])
        by mx.google.com with ESMTPS id x21si5834991pge.803.2018.04.05.09.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 09:42:55 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Date: Thu, 5 Apr 2018 16:42:53 +0000
Message-ID: <DM5PR2101MB1032E85A5BD10B1F1ED17DAFFBBB0@DM5PR2101MB1032.namprd21.prod.outlook.com>
References: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Michal Hocko <mhocko@kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

Hi.

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 72b39cfc4d75 ("mm, memory_hotplug: do not fail offlining too=
 early").

The bot has also determined it's probably a bug fixing patch. (score: 77.74=
60)

The bot has tested the following trees: v4.15.15 .

v4.15.15: Build OK!

--
Thanks.
Sasha=
