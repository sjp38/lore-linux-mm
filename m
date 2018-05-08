Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 269706B000A
	for <linux-mm@kvack.org>; Tue,  8 May 2018 05:46:59 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id e8-v6so23848236qtj.0
        for <linux-mm@kvack.org>; Tue, 08 May 2018 02:46:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k5-v6si441672qti.144.2018.05.08.02.46.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 02:46:58 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w489hvt2045482
	for <linux-mm@kvack.org>; Tue, 8 May 2018 05:46:57 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hu6wff0a7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 May 2018 05:46:56 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <naveen.n.rao@linux.vnet.ibm.com>;
	Tue, 8 May 2018 10:46:54 +0100
Date: Tue, 08 May 2018 15:16:43 +0530
From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 6/9] trace_uprobe: Support SDT markers having reference
 count (semaphore)
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180417043244.7501-7-ravi.bangoria@linux.vnet.ibm.com>
	<20180504134816.8633a157dd036489d9b0f1db@kernel.org>
	<206e4a16-ae21-7da3-f752-853dc2f51947@linux.ibm.com>
	<f3d066d2-a85a-bd21-d4f9-fc27e59135df@linux.ibm.com>
	<20180508005651.45553d3cf72521481d16b801@kernel.org>
In-Reply-To: <20180508005651.45553d3cf72521481d16b801@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Message-Id: <1525772725.o3tzigt8c3.naveen@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>, Ravi Bangoria <ravi.bangoria@linux.ibm.com>
Cc: acme@kernel.org, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, ananth@linux.vnet.ibm.com, corbet@lwn.net, dan.j.williams@intel.com, fengguang.wu@intel.com, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, oleg@redhat.com, pc@us.ibm.com, peterz@infradead.org, rostedt@goodmis.org, srikar@linux.vnet.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com

Masami Hiramatsu wrote:
> On Mon, 7 May 2018 13:51:21 +0530
> Ravi Bangoria <ravi.bangoria@linux.ibm.com> wrote:
>=20
>> BTW, same issue exists for normal uprobe. If uprobe_mmap() fails,
>> there is no feedback to trace_uprobe and no warnigns in dmesg as
>> well !! There was a patch by Naveen to warn such failures in dmesg
>> but that didn't go in: https://lkml.org/lkml/2017/9/22/155
>=20
> Oops, that's a real bug. It seems the ball is in Naveen's hand.
> Naveen, could you update it according to Oleg's comment, and resend it?

Yes, I've had to put that series on the backburner. I will try and get=20
to it soon. Thanks for the reminder.

- Naveen

=
