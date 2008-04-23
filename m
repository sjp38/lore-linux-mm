Received: by wf-out-1314.google.com with SMTP id 25so2142901wfc.11
        for <linux-mm@kvack.org>; Wed, 23 Apr 2008 01:27:46 -0700 (PDT)
Message-ID: <cfd9edbf0804230127k33a56312i6582f926e00ea17@mail.gmail.com>
Date: Wed, 23 Apr 2008 10:27:46 +0200
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <ab3f9b940804171223m722912bfy291a2c6d9d40b24a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080402154910.9588.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <ab3f9b940804141716x755787f5h8e0122c394922a83@mail.gmail.com>
	 <20080417182121.A8CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <ab3f9b940804171223m722912bfy291a2c6d9d40b24a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tom May <tom@tommay.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Tom

On 4/17/08, Tom May <tom@tommay.com> wrote:
>
>  Here is the start and end of the output from the test program.  At
>  each /dev/mem_notify notification Cached decreases, then eventually
>  Mapped decreases as well, which means the amount of time the program
>  has to free memory gets smaller and smaller.  Finally the oom killer
>  is invoked because the program can't react quickly enough to free
>  memory, even though it can free at a faster rate than it can use
>  memory.  My test is slow to free because it calls nanosleep, but this
>  is just a simulation of my actual program that has to perform garbage
>  collection before it can free memory.

I have also seen this behaviour in my static tests with low mem
notification on swapless systems. It is a problem with small programs
(typically static test programs) where the text segment is only a few
pages. I have not seen this behaviour in larger programs which use a
larger working set. As long as the system working set is bigger than
the amount of memory that needs to be allocated, between every
notification reaction opportunity, it seems to be ok.

/Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
