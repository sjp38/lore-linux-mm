Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 196768E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:54:07 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id 49so8849949wra.14
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:54:07 -0800 (PST)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700080.outbound.protection.outlook.com. [40.107.70.80])
        by mx.google.com with ESMTPS id w129si20814634wmb.25.2019.01.14.08.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Jan 2019 08:54:05 -0800 (PST)
From: "Harrosh, Boaz" <Boaz.Harrosh@netapp.com>
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
Date: Mon, 14 Jan 2019 16:54:02 +0000
Message-ID: 
 <MWHPR06MB289605B9E1B4234674CB87E2EE800@MWHPR06MB2896.namprd06.prod.outlook.com>
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
 <20190114135001.w2wpql53zitellus@kshutemo-mobl1>
 <MWHPR06MB2896ACD09C21B2939959C8A8EE800@MWHPR06MB2896.namprd06.prod.outlook.com>,<20190114164004.GL21345@dhcp22.suse.cz>
In-Reply-To: <20190114164004.GL21345@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>

Michal Hocko <mhocko@kernel.org> wrote:

<>
> What does prevent you from mapping a larger area and MAP_FIXED,
> PROT_NONE over it to get the protection?

Yes Thanks I will try. That's good.

>> > For THP, I believe, kernel already does The Right Thing=99 for most us=
ers.
>> > User still may want to get speific range as THP (to avoid false sharin=
g or
>> > something).
>>
>> I'm an OK Kernel programmer.  But I was not able to create a HugePage ma=
pping
>> against /dev/shm/ in a reliable way. I think it only worked on Fedora 28=
/29
>> but not on any other distro/version. (MMAP_HUGE)
>
> Are you mixing hugetlb rather than THP?

Probably. I was looking for the easiest way to get my mmap based memory all=
ocations
to be 2M based instead of 4k. to get better IO characteristics across the K=
ernel.
But I kept getting the 4k pointers. (Can't really remember all the things I=
 tried.)

>> We run with our own compiled Kernel on various distros, THP is configure=
d
>> in but mmap against /dev/shm/ never gives me Huge pages. Does it only
>> work with unanimous mmap ? (I think it is mount dependent which is not
>> in the application control)
>
> If you are talking about THP then you have to enable huge pages for the
> mapping AFAIR.

This is exactly what I was looking to achieve but was not able to do. Most =
probably
a stupid omission on my part, but just to show that it is not that trivial =
and strait
out-of-the-man-page way to do it.  (Would love a code snippet if you ever w=
rote one?)

> --
> Michal Hocko
> SUSE Labs

Thanks man
Boaz
