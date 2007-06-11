Received: by ug-out-1314.google.com with SMTP id m2so1681219uge
        for <linux-mm@kvack.org>; Mon, 11 Jun 2007 12:00:57 -0700 (PDT)
Message-ID: <a0a62dfc0706111200x4c23c285tfa9aebc304a9f3e6@mail.gmail.com>
Date: Mon, 11 Jun 2007 14:00:57 -0500
From: "Adam Litke" <aglitke@gmail.com>
Subject: Re: [PATCH] shm: Fix the filename of hugetlb sysv shared memory
In-Reply-To: <m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com>
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
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Serge E. Hallyn" <serge@hallyn.com>, Albert Cahalan <acahalan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On 6/8/07, Eric W. Biederman <ebiederm@xmission.com> wrote:
> -struct file *hugetlb_zero_setup(size_t size)
> +struct file *hugetlb_file_setup(const char *name, size_t size)

The bulk of this patch seems to handle renaming this function.  Is
that really necessary?

--
Adam Litke ( agl at us.ibm.com )
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
