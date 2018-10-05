Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id C58C76B0010
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 18:31:40 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id h97-v6so5028751lji.21
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 15:31:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s19-v6sor3396497lfb.65.2018.10.05.15.31.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 15:31:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181005222820.GB13613@kroah.com>
References: <20181005192727.167933-1-joel@joelfernandes.org>
 <20181005125339.f6febfd3fcfdc69c6f408c50@linux-foundation.org>
 <20181005211058.GA193964@joelaf.mtv.corp.google.com> <20181005222820.GB13613@kroah.com>
From: Joel Fernandes <joel@joelfernandes.org>
Date: Fri, 5 Oct 2018 15:31:37 -0700
Message-ID: <CAEXW_YSZOCsmtyJnfbvG-P+cQLM8WyohyDGe_FRxi_Xea2aw6Q@mail.gmail.com>
Subject: Re: [PATCH RFC] mm: Add an fs-write seal to memfd
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Al Viro <viro@zeniv.linux.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, Oct 5, 2018 at 3:28 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Fri, Oct 05, 2018 at 02:10:58PM -0700, Joel Fernandes wrote:
>> On Fri, Oct 05, 2018 at 12:53:39PM -0700, Andrew Morton wrote:
>> > On Fri,  5 Oct 2018 12:27:27 -0700 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
>> >
>> > > To support the usecase, this patch adds a new F_SEAL_FS_WRITE seal which
>> > > prevents any future mmap and write syscalls from succeeding while
>> > > keeping the existing mmap active. The following program shows the seal
>> > > working in action:
>> >
>> > Please be prepared to create a manpage patch for this one.
>>
>> Sure, I will do that. thanks,
>
> And a test case to the in-kernel memfd tests would be appreciated.


Sure, I will do add to those self-tests.

thanks,

 - Joel
