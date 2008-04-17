Received: by yw-out-1718.google.com with SMTP id 6so178662ywa.26
        for <linux-mm@kvack.org>; Thu, 17 Apr 2008 16:24:48 -0700 (PDT)
Message-ID: <e9c3a7c20804171624n43a3665dkfea4d474aac4c99e@mail.gmail.com>
Date: Thu, 17 Apr 2008 16:24:48 -0700
From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: 2.6.25-mm1: not looking good
In-Reply-To: <20080417160331.b4729f0c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 4:03 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
>  I repulled all the trees an hour or two ago, installed everything on an
>  8-way x86_64 box and:
>
>
[..]
>  more usb/sysfs:
>
>  hub 2-0:1.0: USB hub found
>  hub 2-0:1.0: 2 ports detected
>  sysfs: duplicate filename '189:128' can not be created
[..]
>  I have maybe two hours in which to weed out whatever very-recently-added
>  dud patches are causing this.  Any suggestions are welcome.
>

The duplicate filename <major>:<minor> messages are coming from
"sysfs-add-sys-dev-char-block-to-lookup-sysfs-path-by-major-minor.patch"
now in Greg's tree.  I'll take a look.

--
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
