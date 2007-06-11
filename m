Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id l5BKrnUc029053
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 13:53:49 -0700
Received: from an-out-0708.google.com (anab33.prod.google.com [10.100.53.33])
	by zps75.corp.google.com with ESMTP id l5BKrjrZ031646
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 13:53:46 -0700
Received: by an-out-0708.google.com with SMTP id b33so385967ana
        for <linux-mm@kvack.org>; Mon, 11 Jun 2007 13:53:44 -0700 (PDT)
Message-ID: <b040c32a0706111353x7ec86054x8656bbdde02adc47@mail.gmail.com>
Date: Mon, 11 Jun 2007 13:53:44 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH] shm: Fix the filename of hugetlb sysv shared memory
In-Reply-To: <a0a62dfc0706111200x4c23c285tfa9aebc304a9f3e6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	 <20070606204432.b670a7b1.akpm@linux-foundation.org>
	 <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	 <20070607162004.GA27802@vino.hallyn.com>
	 <m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
	 <46697EDA.9000209@us.ibm.com>
	 <m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com>
	 <a0a62dfc0706111200x4c23c285tfa9aebc304a9f3e6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <aglitke@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, "Serge E. Hallyn" <serge@hallyn.com>, Albert Cahalan <acahalan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On 6/11/07, Adam Litke <aglitke@gmail.com> wrote:
> On 6/8/07, Eric W. Biederman <ebiederm@xmission.com> wrote:
> > -struct file *hugetlb_zero_setup(size_t size)
> > +struct file *hugetlb_file_setup(const char *name, size_t size)
>
> The bulk of this patch seems to handle renaming this function.  Is
> that really necessary?

It looks OK to me though, because the argument list to that function
is changed.  Avoid change the function name isn't going to reduce the
patch size either.  So we might just change the name as well to match
the function name shmem_file_setup().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
