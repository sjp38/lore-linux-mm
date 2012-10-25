Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 55CEC6B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 06:47:02 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so1516630iak.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 03:47:01 -0700 (PDT)
Message-ID: <5089189D.4050401@gmail.com>
Date: Thu, 25 Oct 2012 18:46:53 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: MMTests 0.06
References: <20121012145114.GZ29125@suse.de> <CALF0-+UBq8kgC-uUkuk_akoyBgvkytgn0v+2uBTDLZcFCPeHrQ@mail.gmail.com> <20121025102028.GB2558@suse.de>
In-Reply-To: <20121025102028.GB2558@suse.de>
Content-Type: multipart/alternative;
 boundary="------------010706030301070401060909"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------010706030301070401060909
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

On 10/25/2012 06:20 PM, Mel Gorman wrote:
> On Wed, Oct 24, 2012 at 05:14:31PM -0300, Ezequiel Garcia wrote:
>>> The stats reporting still needs work because while some tests know how
>>> to make a better estimate of mean by filtering outliers it is not being
>>> handled consistently and the methodology needs work. I know filtering
>>> statistics like this is a major flaw in the methodology but the decision
>>> was made in this case in the interest of the benchmarks with unstable
>>> results completing in a reasonable time.
>>>
>> FWIW, I found a minor problem with sudo and yum incantation when trying this.
>>
>> I'm attaching a patch.
>>
> Thanks very much. I've picked it up and it'll be in MMTests 0.07.

Hi Gorman,

Could MMTests 0.07 auto download related packages for different 
distributions?

Regards,
Chen

>


--------------010706030301070401060909
Content-Type: text/html; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-15"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 10/25/2012 06:20 PM, Mel Gorman
      wrote:<br>
    </div>
    <blockquote cite="mid:20121025102028.GB2558@suse.de" type="cite">
      <pre wrap="">On Wed, Oct 24, 2012 at 05:14:31PM -0300, Ezequiel Garcia wrote:
</pre>
      <blockquote type="cite">
        <blockquote type="cite">
          <pre wrap="">The stats reporting still needs work because while some tests know how
to make a better estimate of mean by filtering outliers it is not being
handled consistently and the methodology needs work. I know filtering
statistics like this is a major flaw in the methodology but the decision
was made in this case in the interest of the benchmarks with unstable
results completing in a reasonable time.

</pre>
        </blockquote>
        <pre wrap="">
FWIW, I found a minor problem with sudo and yum incantation when trying this.

I'm attaching a patch.

</pre>
      </blockquote>
      <pre wrap="">
Thanks very much. I've picked it up and it'll be in MMTests 0.07.</pre>
    </blockquote>
    <br>
    Hi Gorman,<br>
    <br>
    Could MMTests 0.07 auto download related packages for different
    distribution<span style="color: rgb(0, 0, 0); font-family: arial,
      sans-serif; font-size: 12px; font-style: normal; font-variant:
      normal; font-weight: normal; letter-spacing: normal; line-height:
      15px; orphans: 2; text-align: -webkit-auto; text-indent: 0px;
      text-transform: none; white-space: normal; widows: 2;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px; background-color: rgb(250, 250,
      250); display: inline !important; float: none; "></span>s?<br>
    <br>
    Regards,<br>
    Chen<br>
    <br>
    <blockquote cite="mid:20121025102028.GB2558@suse.de" type="cite">
      <pre wrap="">

</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------010706030301070401060909--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
