Message-ID: <40365A0F.8070003@movaris.com>
Date: Fri, 20 Feb 2004 11:03:43 -0800
From: Kirk True <ktrue@movaris.com>
MIME-Version: 1.0
Subject: Re: LTP VM test slower under 2.6.3 than 2.4.20
References: <40363778.20900@movaris.com> <3800000.1077295177@[10.10.2.4]> <40365887.6020204@movaris.com>
In-Reply-To: <40365887.6020204@movaris.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirk True <ktrue@movaris.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, kernelnewbies <kernelnewbies@nl.linux.org>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

OK, try this profile for 2.4.20 instead (helps to use the right System.map):

    221 default_idle                               4.6042
      2 error_code                                 0.0333
      1 restore_fpu                                0.0312
     12 apm_bios_call_simple                       0.0833
      6 do_page_fault                              0.0047
      1 do_anonymous_page                          0.0039
      1 pte_alloc                                  0.0057
      2 set_page_dirty                             0.0179
      1 add_to_page_cache_unique                   0.0078
      2 mark_page_accessed                         0.0417
      1 kmem_cache_free                            0.0208
      1 activate_page                              0.0078
      1 lru_cache_add                              0.0104
      2 __lru_cache_del                            0.0179
     14 shrink_cache                               0.0179
      3 swap_out_pmd                               0.0117
      2 try_to_swap_out                            0.0048
      2 __free_pages_ok                            0.0030
      7 rmqueue                                    0.0129
      1 try_to_free_buffers                        0.0039
      1 ide_dmaproc                                0.0012
     53 fast_clear_page                            0.6625
    337 total                                      0.0003

Kirk


Kirk True wrote:

> Hi all,
> 
>  > A kernel profile might help.
> 
> Here's the profiles comparing the two versions. I don't understand why
> no "do_page_fault" shows up under 2.4.20 or why "gunzip" does.
> 
> Kirk
> 
> -------------------------------------------------
> 
> 
> 
> 2.6.3:
> 
> # readprofile -r;./mem01;readprofile -m /boot/System.map-2.6.3 \
>        >> captured_profile2.6.3
> 
>    1446 poll_idle                                 24.9310
>       4 delay_tsc                                  0.1667
>      71 do_page_fault                              0.0536
>      41 schedule                                   0.0238
>      13 __might_sleep                              0.0637
>       1 prepare_to_wait                            0.0068
>       1 put_files_struct                           0.0042
>    3229 do_softirq                                16.3081
>       1 run_timer_softirq                          0.0022
>    4807 total                                      0.0262
> 
> 
> 
> 2.4.20:
> 
> # readprofile -r;./mem01;readprofile -m /boot/System.map-2.4.20 \
>        >> captured_profile2.4.20
> 
>     347 gunzip                                     0.1559
>       8 acpi_restore_state_mem                     0.0021
>       2 proc_dostring                              0.0033
>       3 access_process_vm                          0.0054
>       2 __mod_timer                                0.0038
>       1 del_timer                                  0.0065
>       1 update_one_process                         0.0036
>       1 notifier_chain_unregister                  0.0052
>     365 total                                      0.0020
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
