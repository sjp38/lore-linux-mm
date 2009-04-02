Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 12D506B0055
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 02:00:57 -0400 (EDT)
Received: by bwz3 with SMTP id 3so447694bwz.38
        for <linux-mm@kvack.org>; Wed, 01 Apr 2009 23:00:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090402055906.GH1117@x200.localdomain>
References: <20090331150218.GS9137@random.random>
	 <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws>
	 <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws>
	 <20090402012215.GE1117@x200.localdomain>
	 <49D424AF.3090806@codemonkey.ws>
	 <20090402054816.GG1117@x200.localdomain>
	 <36ca99e90904012257j5f5e6e2co673ff2433d49b7b9@mail.gmail.com>
	 <20090402055906.GH1117@x200.localdomain>
Date: Thu, 2 Apr 2009 08:00:56 +0200
Message-ID: <36ca99e90904012300s57c9f030xa70f028216c3da2a@mail.gmail.com>
Subject: Re: [PATCH 4/4 alternative userspace] add ksm kernel shared memory
	driver
From: Bert Wesarg <bert.wesarg@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 2, 2009 at 07:59, Chris Wright <chrisw@redhat.com> wrote:
> * Bert Wesarg (bert.wesarg@googlemail.com) wrote:
>> > Unregister a shareable memory region (not currently implemented):
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0^^=
^^^^^^^^^^^^^^^^^^^^^^^
>> > madvise(void *addr, size_t len, MADV_UNSHAREABLE)
>> I can't find a definition for MADV_UNSHAREABLE!
>
> It's not there ;-)
>
Thanks ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
