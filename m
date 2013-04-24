Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A8FDE6B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 19:40:10 -0400 (EDT)
Received: by mail-da0-f46.google.com with SMTP id x4so574332daj.33
        for <linux-mm@kvack.org>; Wed, 24 Apr 2013 16:40:09 -0700 (PDT)
Message-ID: <51786D52.1080509@gmail.com>
Date: Thu, 25 Apr 2013 07:40:02 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <20130410080202.GB21292@blaptop> <517861E0.7030801@zytor.com>
In-Reply-To: <517861E0.7030801@zytor.com>
Content-Type: multipart/alternative;
 boundary="------------070208070203030706080106"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------070208070203030706080106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Peter,
On 04/25/2013 06:51 AM, H. Peter Anvin wrote:
> On 04/10/2013 01:02 AM, Minchan Kim wrote:
>> When I am looking at the code, I was wonder about the logic of GHZP(aka,
>> get_huge_zero_page) reference handling. The logic depends on that page
>> allocator never alocate PFN 0.
>>
>> Who makes sure it? What happens if allocator allocates PFN 0?
>> I don't know all of architecture makes sure it.
>> You investigated it for all arches?
>>
> This isn't manifest, right?  At least on x86 we should never, ever
> allocate PFN 0.

I see in memblock_trim_memory(): start = round_up(orig_start, align); 
here align is PAGE_SIZE, so the dump of zone ranges in my machine is [  
   0.000000]  DMA      [mem 0x00001000-0x00ffffff]. Why PFN 0 is not 
used? just for align?

>
> 	-hpa
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--------------070208070203030706080106
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">Hi Peter,<br>
      On 04/25/2013 06:51 AM, H. Peter Anvin wrote:<br>
    </div>
    <blockquote cite="mid:517861E0.7030801@zytor.com" type="cite">
      <pre wrap="">On 04/10/2013 01:02 AM, Minchan Kim wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">
When I am looking at the code, I was wonder about the logic of GHZP(aka,
get_huge_zero_page) reference handling. The logic depends on that page
allocator never alocate PFN 0.

Who makes sure it? What happens if allocator allocates PFN 0?
I don't know all of architecture makes sure it.
You investigated it for all arches?

</pre>
      </blockquote>
      <pre wrap="">
This isn't manifest, right?  At least on x86 we should never, ever
allocate PFN 0.</pre>
    </blockquote>
    <br>
    I see in memblock_trim_memory(): start = round_up(orig_start,
    align); here align is PAGE_SIZE, so the dump of zone ranges in my
    machine is
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <span style="color: rgb(0, 0, 0); font-family: song, Verdana;
      font-size: 14px; font-style: normal; font-variant: normal;
      font-weight: normal; letter-spacing: normal; line-height:
      22.390625px; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
      255); display: inline !important; float: none;">[&nbsp; &nbsp; 0.000000]&nbsp;
      &nbsp;DMA&nbsp; &nbsp;&nbsp; &nbsp;[mem 0x00001000-0x00ffffff]. Why PFN 0 is not used? just
      for align?</span><br>
    <br>
    <blockquote cite="mid:517861E0.7030801@zytor.com" type="cite">
      <pre wrap="">

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to <a class="moz-txt-link-abbreviated" href="mailto:majordomo@kvack.org">majordomo@kvack.org</a>.  For more info on Linux MM,
see: <a class="moz-txt-link-freetext" href="http://www.linux-mm.org/">http://www.linux-mm.org/</a> .
Don't email: &lt;a href=mailto:<a class="moz-txt-link-rfc2396E" href="mailto:dont@kvack.org">"dont@kvack.org"</a>&gt; <a class="moz-txt-link-abbreviated" href="mailto:email@kvack.org">email@kvack.org</a> &lt;/a&gt;
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------070208070203030706080106--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
