Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 324586B000D
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 23:29:14 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p12-v6so15221130iog.8
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 20:29:14 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j9-v6si5947065itc.115.2018.07.13.20.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 20:29:13 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6E3TCH9028361
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 03:29:12 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2k2p7vspq6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 03:29:12 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6E3TB4q010622
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 03:29:11 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6E3TAo1031738
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 03:29:11 GMT
Received: by mail-oi0-f50.google.com with SMTP id w126-v6so65727729oie.7
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 20:29:10 -0700 (PDT)
MIME-Version: 1.0
References: <CA+55aFyARQV302+mXNYznrOOjzW+yxbcv+=OkD43dG6G1ktoMQ@mail.gmail.com>
 <alpine.DEB.2.21.1807140031440.2644@nanos.tec.linutronix.de>
 <CA+55aFzBx1haeM2QSFvhaW2t_HVK78Y=bKvsiJmOZztwkZ-y7Q@mail.gmail.com>
 <CA+55aFzVGa57apuzDMBLgWQQRcm3BNBs1UEg-G_2o7YW1i=o2Q@mail.gmail.com>
 <CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com>
 <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
 <CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
 <20180713165812.ec391548ffeead96725d044c@linux-foundation.org>
 <9b93d48c-b997-01f7-2fd6-6e35301ef263@oracle.com> <CA+55aFxFw2-1BD2UBf_QJ2=faQES_8q==yUjwj4mGJ6Ub4uX7w@mail.gmail.com>
 <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com> <CA+55aFwPAwczHS3XKkEnjY02PaDf2mWrcqx_hket4Ce3nScsSg@mail.gmail.com>
 <CAGM2rebeo3UUo2bL6kXCMGhuM36wjF5CfvqGG_3rpCfBs5S2wA@mail.gmail.com> <CA+55aFxetyCqX2EzFBDdHtriwt6UDYcm0chHGQUdPX20qNHb4Q@mail.gmail.com>
In-Reply-To: <CA+55aFxetyCqX2EzFBDdHtriwt6UDYcm0chHGQUdPX20qNHb4Q@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 13 Jul 2018 23:28:34 -0400
Message-ID: <CAGM2rebDrxzpEduisi6OeNhSkfCNbkwpp6YQ4Pqic2k23kSg0g@mail.gmail.com>
Subject: Re: Instability in current -git tree
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, willy@infradead.org, mingo@redhat.com, axboe@kernel.dk, gregkh@linuxfoundation.org, davem@davemloft.net, viro@zeniv.linux.org.uk, airlied@gmail.com, Tejun Heo <tj@kernel.org>, tytso@google.com, snitzer@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, neelx@redhat.com, mgorman@techsingularity.net

On Fri, Jul 13, 2018 at 11:25 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Fri, Jul 13, 2018 at 8:04 PM Pavel Tatashin
> <pasha.tatashin@oracle.com> wrote:
> >
> > > You can't just memset() the 'struct page' to zero after it's been set up.
> >
> > That should not be happening, unless there is a bug.
>
> Well, it does seem to happen. My memory stress-tester has been running
> for about half an hour now with the revert I posted - it used to
> trigger the problem in maybe ~5 minutes before.
>
> So I do think that revert fixes it for me. No guarantees, but since I
> figured out how to trigger it, it's been fairly reliable.
>
> > We want to zero those struct pages so we do not have uninitialized
> > data accessed by various parts of the code that rounds down large
> > pages and access the first page in section without verifying that the
> > page is valid. The example of this is described in commit that
> > introduced zero_resv_unavail()
>
> I'm attaching the relevant (?) parts of dmesg, which has the node
> ranges, maybe you can see what the problem with the code is.
>
> (NOTE! This dmesg is with that "mem=6G" command line option, which causes that
>
>   e820: remove [mem 0x180000000-0xfffffffffffffffe] usable
>
> line - that's just because it's my stress-test boot. It happens with
> or without it, but without the "mem=6G" it took days to trigger).
>
> I'm more than willing to test patches (either for added information or
> for testing fixes), although I think I'm getting off the computer for
> today.

Thank you. I am ok with reverting these patches. I will study the bug
that was introduced by
"f7f99100d8d9 mm: stop zeroing memory during allocation in vmemmap",
and post a fixed version later.

Thank you,
Pavel
