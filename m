Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id E5A1C6B4978
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:06:58 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id s10so22381104iop.16
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:06:58 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z18si3009934ioj.17.2018.11.27.09.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 09:06:57 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [RFC PATCH 3/3] mm, proc: report PR_SET_THP_DISABLE in proc
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <283f38d9-1142-60b6-0b84-7129b7f9781e@suse.cz>
Date: Tue, 27 Nov 2018 10:06:50 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <5CB5F808-ECA8-4A4E-B942-7D69522E3FA4@oracle.com>
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-4-mhocko@kernel.org>
 <0ACDD94B-75AD-4DD0-B2E3-32C0EDFBAA5E@oracle.com>
 <20181127131707.GW12455@dhcp22.suse.cz>
 <04647F77-FE93-4A8E-90C1-4245709B88A5@oracle.com>
 <283f38d9-1142-60b6-0b84-7129b7f9781e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>



> On Nov 27, 2018, at 9:50 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
> On 11/27/18 3:50 PM, William Kucharski wrote:
>>=20
>> I was just double checking that this was meant to be more of a check =
done
>> before code elsewhere performs additional checks and does the actual =
THP
>> mapping, not an all-encompassing go/no go check for THP mapping.
>=20
> Yes, the code doing the actual mapping is still checking also =
alignment etc.

Thanks, yes, that is what I was getting at.
