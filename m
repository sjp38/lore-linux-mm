Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90C926B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 14:09:38 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w131so75211013qka.5
        for <linux-mm@kvack.org>; Wed, 24 May 2017 11:09:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a81si237952qkh.320.2017.05.24.11.09.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 11:09:34 -0700 (PDT)
Subject: Re: [RFC PATCH v2 12/17] cgroup: Remove cgroup v2 no internal process
 constraint
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-13-git-send-email-longman@redhat.com>
 <20170519203824.GC15279@wtj.duckdns.org>
 <93a69664-4ba6-9ee8-e4ea-ce76b6682c77@redhat.com>
 <20170524170527.GH24798@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <2642542c-3002-73ec-b386-ca0d38f57021@redhat.com>
Date: Wed, 24 May 2017 14:09:30 -0400
MIME-Version: 1.0
In-Reply-To: <20170524170527.GH24798@htj.duckdns.org>
Content-Type: multipart/alternative;
 boundary="------------F2D2BFF9B58180D354D45682"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

This is a multi-part message in MIME format.
--------------F2D2BFF9B58180D354D45682
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/24/2017 01:05 PM, Tejun Heo wrote:
> Hello,
>
> On Mon, May 22, 2017 at 12:56:08PM -0400, Waiman Long wrote:
>> All controllers can use the special sub-directory if userland chooses =
to
>> do so. The problem that I am trying to address in this patch is to all=
ow
>> more natural hierarchy that reflect a certain purpose, like the task
>> classification done by systemd. Restricting tasks only to leaf nodes
>> makes the hierarchy unnatural and probably difficult to manage.
> I see but how is this different from userland just creating the leaf
> cgroup?  I'm not sure what this actually enables in terms of what can
> be achieved with cgroup.  I suppose we can argue that this is more
> convenient but I'd like to keep the interface orthogonal as much as
> reasonably possible.
>
> Thanks.
>
I am just thinking that it is a bit more natural with the concept of the
special resource domain sub-directory. You are right that the same
effect can be achieved by proper placement of tasks and enabling of
controllers.

A (cpu,memory) [T1] - B(cpu,memory) [T2]
                                  \ cgroups.resource_domain (memory)

A (cpu,memory)  - B(cpu,memory) [T2]
                            \ C (memory) [T1]

With respect to the tasks T1 and T2, the above 2 configurations are the
same.

I am OK to drop this patch. However, I still think the current
no-internal process constraint is too restricting. I will suggest either

 1. Allow internal processes and document the way to avoid internal
    process competition as shown above from the userland, or
 2. Mark only certain controllers as not allowing internal processes
    when they are enabled.

What do you think about this?

Cheers,
Longman

--------------F2D2BFF9B58180D354D45682
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta content="text/html; charset=windows-1252"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 05/24/2017 01:05 PM, Tejun Heo
      wrote:<br>
    </div>
    <blockquote cite="mid:20170524170527.GH24798@htj.duckdns.org"
      type="cite">
      <pre wrap="">Hello,

On Mon, May 22, 2017 at 12:56:08PM -0400, Waiman Long wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">All controllers can use the special sub-directory if userland chooses to
do so. The problem that I am trying to address in this patch is to allow
more natural hierarchy that reflect a certain purpose, like the task
classification done by systemd. Restricting tasks only to leaf nodes
makes the hierarchy unnatural and probably difficult to manage.
</pre>
      </blockquote>
      <pre wrap="">
I see but how is this different from userland just creating the leaf
cgroup?  I'm not sure what this actually enables in terms of what can
be achieved with cgroup.  I suppose we can argue that this is more
convenient but I'd like to keep the interface orthogonal as much as
reasonably possible.

Thanks.

</pre>
    </blockquote>
    <p>I am just thinking that it is a bit more natural with the concept
      of the special resource domain sub-directory. You are right that
      the same effect can be achieved by proper placement of tasks and
      enabling of controllers.</p>
    <p>A (cpu,memory) [T1] - B(cpu,memory) [T2]<br>
                                        \ cgroups.resource_domain
      (memory)</p>
    <p>A (cpu,memory)  - B(cpu,memory) [T2]<br>
                                  \ C (memory) [T1]<br>
    </p>
    <p>With respect to the tasks T1 and T2, the above 2 configurations
      are the same.</p>
    <p>I am OK to drop this patch. However, I still think the current
      no-internal process constraint is too restricting. I will suggest
      either<br>
    </p>
    <ol>
      <li>Allow internal processes and document the way to avoid
        internal process competition as shown above from the userland,
        or</li>
      <li>Mark only certain controllers as not allowing internal
        processes when they are enabled.</li>
    </ol>
    What do you think about this?<br>
    <br>
    Cheers,<br>
    Longman<br>
  </body>
</html>

--------------F2D2BFF9B58180D354D45682--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
