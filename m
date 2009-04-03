Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B78506B003D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 07:08:17 -0400 (EDT)
Message-ID: <49D5EE1F.4060009@redhat.com>
Date: Fri, 03 Apr 2009 13:08:15 +0200
From: Gerd Hoffmann <kraxel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/4] update ksm userspace interfaces
References: <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <20090402012215.GE1117@x200.localdomain> <49D424AF.3090806@codemonkey.ws> <20090402053114.GF1117@x200.localdomain> <49D4BE64.8020508@redhat.com> <49D5E1EE.6030707@redhat.com> <49D5E9B5.1020101@redhat.com>
In-Reply-To: <49D5E9B5.1020101@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Chris Wright <chrisw@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> Gerd Hoffmann wrote:
>> Did you test whenever it really cleans up in case you "kill -9 qemu"?
>>
>> I recently did something simliar with the result that the extra
>> reference hold on mm_struct prevented the process memory from being
>> zapped ...
>>
>> cheers,
>>   Gerd
>>   
> Did you use mmput() after you called get_task_mm() ???
> get_task_mm() do nothing beside atomic_inc(&mm->mm_users);

mmput() call was in ->release() callback, ->release() in turn never was
called because the kernel didn't zap the mappings because of the
reference ...

The driver *also* created mappings which ksmctl doesn't, so it could be
you don't run into this issue.

cheers,
  Gerd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
